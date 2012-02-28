#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Manages the influx of scan monitoring data to determine if tickets for vulnerabilities should be created, if so,
# fires off actual ticket creation.
#
# == Author
# Christopher Lee chrsitopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

require 'rex/parser/nexpose_xml'
require 'singleton'

class TicketManager < Poller
  include Singleton

  public
  ######################################################################################################################
  # PUBLIC METHODS                                                                                                     #
  ######################################################################################################################

  #---------------------------------------------------------------------------------------------------------------------
  # Observed scan managers update this class with scan details here.
  #
  # scan_info - Hash that contains: (:scan_id, :status, :message, :host)
  #---------------------------------------------------------------------------------------------------------------------
  def update(scan_info)
    status = scan_info[:status].to_s
    if status =~ /finished/i || status =~/stopped/i
      has_ticket = false
      @ticket_processing_queue.each do |ticket|
        # If this ticket is already in the process queue then don't add.
        if ticket[:scan_id].to_i == scan_info[:scan_id].to_i && ticket[:host].to_s.eql?(scan_info[:host].to_s)
          has_ticket = true
          break
        end
      end

      unless has_ticket
        # TODO: Error checking
        scan_id = scan_info[:scan_id]
        scan_summary = ScanSummary.find_by_scan_id(scan_id)
        if scan_summary
          site_id = scan_summary[:site_id]
          @ticket_processing_queue << {
              :scan_id => scan_id,
              :site_id => site_id,
              :host    => scan_info[:host]
          }
        end
      end
    end
  end

  private
  ######################################################################################################################
  # PRIVATE METHODS                                                                                                    #
  ######################################################################################################################

  #---------------------------------------------------------------------------------------------------------------------
  # Private initializer.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    # An array of scan-id to create tickets from
    @ticket_processing_queue = []

    # Processes data from the XML export and stores
    # tickets to be processed in the database
    @ticket_aggregator = TicketAggregator.new

    # 3 vulnerable states
    @vulnerable_markers = %w(vulnerable-exploited vulnerable-version potential)

    @logger = LogManager.instance

    start_poller('nsc_polling', 'Ticket Manager')

    # Now add self to the scan manager observer list
    ScanManager.instance.add_observer(self)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # The default poller method fires and calls this method.
  # There is only one process thread, threrefore considerations for multi-threads
  # are not needed.
  #---------------------------------------------------------------------------------------------------------------------
  def process
    ticket_to_be_processed = @ticket_processing_queue.first

    # Builds the tickets and stores them in the DB
    build_and_store_tickets(ticket_to_be_processed) if ticket_to_be_processed

    # Call this method regardless to ensure we re-attempt to create failed tickets
    # Actually writes out the tickets to the ticketing client
    handle_tickets
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Ensure the vulnerability status defines a vulnerable threat.
  #---------------------------------------------------------------------------------------------------------------------
  def is_vulnerable?(vuln_status)
    @vulnerable_markers.include?(vuln_status.to_s.chomp)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the nexpose device ID  for a certain IP.
  #
  # ip -
  # site_device_listing -
  #
  # device_info[:address] is always an ip
  #---------------------------------------------------------------------------------------------------------------------
  def get_device_id(ip, site_device_listing)
    raise ArgumentError.new('Site device listing was null @ TicketManager#get_device_id') unless site_device_listing

    site_device_listing.each do |device_info|
      device_info[:device_id] if  device_info[:address] =~ /#{ip}/
    end
  end


  #---------------------------------------------------------------------------------------------------------------------
  # Performs ticket creation.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_tickets
    begin
      tickets_created_without_error = true

      ticket_configs = TicketConfig.all
      ticket_to_be_created_ids = TicketsToBeCreated.find_by_sql('select id from tickets_to_be_createds')

      return if ticket_to_be_created_ids.empty?

      # We need to first get a list of all the current ticketing modules (ACTIVE OFFCOURSE)
      ticket_configs.each do |ticket_config|
        # Don't process inactive modules
        next unless ticket_config.is_active

        # Load rule manager for each config
        rule_manager = RuleManager.new(ticket_config.ticket_rule)

        # The module name is an integral part of knowing when to ticket
        module_name = ticket_config.module_name

        c = Object.const_get(ticket_config.ticket_client_type.to_s)

        ticket_client_info = TicketClients.find_by_client(c.client_name)
        client_connector = ticket_client_info.client_connector.to_s

        # Initialize the ticket client
        ticket_client = Object.const_get(client_connector).new ticket_config

        tickets_created = 0
        ticket_to_be_created_ids.each do |ticket_to_be_created_id|

          ticket_to_be_created = TicketsToBeCreated.find(ticket_to_be_created_id)
          ticket_data          = ticket_to_be_created.ticket_data
          ticket_id            = ticket_to_be_created.ticket_id

          host = ticket_data[:nsc_host]

          # Skip if ticket already created or rules don't match.
          next if created_already?(host, module_name, ticket_id) || !rule_manager.matches_rules?(ticket_data)

          # Decode the proof.
          ticket_data[:proof] = Util.process_db_input_array(ticket_data[:proof])

          # Append the ticket configurations
          ticket_data[:ticketing_data] = ticket_config
          ticket_data[:formatter]      = ticket_client_info.formatter

          msg = ticket_client.insert_ticket(ticket_data)

          if !msg.nil? and !msg[0]
            @logger.add_log_message "[!] Ticketing error: #{msg[1]}"
            tickets_created_without_error = false
            break
          elsif !msg.nil? and msg[0]
            # Add ticket as already created
            TicketsCreated.create(:host => host, :module_name => module_name, :ticket_id => ticket_id)
            tickets_created = tickets_created + 1
          end

        end
        # TODO: Fix later
        #@logger.add_log_message "[*} Created #{tickets_created} tickets for host: #{host} and module: #{module_name}"

      end

      # We don't remove tickets unless all were created successfully
      # TODO: Make this more granular - low-priority
      if tickets_created_without_error
        TicketsToBeCreated.destroy_all
      end

    rescue Exception => e
      @logger.add_log_message "[!] Error in ticket handling: #{e.backtrace}"
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Creates a ticket key
  #---------------------------------------------------------------------------------------------------------------------
  def build_key(ticket)
    key = ''
    key << ticket[:device].to_s
    key << '|'
    key << ticket[:port].to_s
    key << '|'
    key << ticket[:vuln_id].to_s
    key << '|'
    key << ticket[:vkey].to_s
    key
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Reads in tickets to be created and converts to array of hash
  #---------------------------------------------------------------------------------------------------------------------
  def load_tickets_to_be_created
    begin

      tickets_to_be_created = TicketsToBeCreated.all
      tickets = []

      tickets_to_be_created.each do |ticket_to_be_created|
        ticket_id = ticket_to_be_created.ticket_id
        ticket_data = ticket_to_be_created.ticket_data
        ticket_data[:ticket_id] = ticket_id
        tickets << ticket_data
      end

      tickets
    rescue Exception => e
      @logger.add_log_message "[!] Error in loading tickets: #{e.backtrace}"
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets whether or not this ticket is already in the creation queue
  #---------------------------------------------------------------------------------------------------------------------
  def ticket_in_creation_queue?(ticket_id)
    ticket_to_be_created = TicketsToBeCreated.find_by_ticket_id(ticket_id)
    (not ticket_to_be_created.nil?)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # TODO: This changes when ticket scopes are added
  # @retuns true iff the ticket has already been created for this host, model and ticket_id
  #---------------------------------------------------------------------------------------------------------------------
  def created_already?(host, module_name, ticket_id)
    tickets_created = TicketsCreated.find_by_host_and_module_name_and_ticket_id(host, module_name, ticket_id)
    (not tickets_created.nil?)
  end

end
