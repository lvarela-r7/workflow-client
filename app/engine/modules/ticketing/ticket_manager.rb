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
  ##################
  # PUBLIC METHODS #
  ##################

  #---------------------------------------------------------------------------------------------------------------------
  # Observed scan managers update this class with scan details here.
  #
  # @param scan_info - Hash that contains: (:scan_id, :status, :message, :host)
  #---------------------------------------------------------------------------------------------------------------------
  def update scan_info
    status = scan_info[:status].to_s
    if (status =~ /finished/i || status =~/stopped/i)
      has_ticket = false
      @ticket_processing_queue.each do |ticket|
        # If this ticket is already in the process queue then don't add.
        if (ticket[:scan_id].to_i == scan_info[:scan_id].to_i && ticket[:host].to_s.eql?(scan_info[:host].to_s))
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
  ##################
  # PRIVATE METHODS#
  ##################

  #---------------------------------------------------------------------------------------------------------------------
  # Private initializer.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    # An array of scan-id to create tickets from
    @ticket_processing_queue = []

    load_vuln_map

    #TODO: Move to DB (low-low priority)
    @vulnerable_markers = ['vulnerable-exploited', 'vulnerable-version', 'potential']

    @logger = LogManager.instance

    start_poller('nsc_polling', 'Ticket Manager')

    # Now add self to the scan manager observer list
    ScanManager.instance.add_observer(self)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # The default poller method fired.
  #---------------------------------------------------------------------------------------------------------------------
  def process
    processing_ticket = @ticket_processing_queue.first

    if processing_ticket
      # Builds the tickets and stores them in the DB
      build_and_store_tickets processing_ticket
    end

    # Call this method regardless to ensure we re-attempt to create failed tickets
    # Actually writes out the tickets to the ticketing client
    handle_tickets
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns an array of ticket data:
  #
  #   ip - The device IP address
  #   device_id
  #   name
  #   fingerprint - The fingerprint is built from highest certainty
  #   vuln_id
  #   vuln_status - Vulnerability identifiers: vuln version, potential, etc ...
  #   port
  #   protocol
  #   vkey
  #   proof
  #   ticket_key
  #
  # site_device_listing -
  # host_data_array -
  #
  #---------------------------------------------------------------------------------------------------------------------
  def build_ticket_data(site_device_listing, host_data_array)
    begin
      res = []
      host_data_array.each do |host_data|
        ip          = host_data["addr"]
        names       = host_data["names"]
        device_id   = get_device_id(ip, site_device_listing)

        # Just take the first name
        name = ''
        if (!names.nil? || !names.empty?)
          name = names[0]
        end

        fingerprint = ''
        fingerprint << (host_data["os_vendor"] || '')
        fingerprint << ' '
        fingerprint << (host_data["os_family"] || '')

        host_data["vulns"].each { |vuln_id, vuln_info|
          vuln_status = vuln_info["status"]

          # Currently only 've' and 'vv' are parsed
          # we will do the status check regardless to
          # ensure we never break
          unless (is_vulnerable?(vuln_status))
            next
          end

          vkey = (vuln_info["key"] || '')
          vuln_endpoint_data = vuln_info["endpoint_data"]

          port = ''
          protocol = ''
          if (vuln_endpoint_data)
            port = (vuln_endpoint_data["port"] || '')
            protocol = (vuln_endpoint_data["protocol"] || '')
          end

          # Format to avoid weird DB issues
          proof = process_db_input_array(vuln_info['proof'], true)

          res << {
              :ip => ip,
              :device_id => device_id,
              :name => name,
              :fingerprint => fingerprint,
              :vuln_id => vuln_id,
              :vuln_status => vuln_status,
              :port => port,
              :protocol => protocol,
              :vkey => vkey,
              :proof => proof
          }
        }
      end
    rescue Exception => e
      @logger.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"
    end

    res
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Ensure the vulnerability status defines a vulnerable threat.
  #---------------------------------------------------------------------------------------------------------------------
  def is_vulnerable? vuln_status
    @vulnerable_markers.include?(vuln_status.to_s.chomp)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # device_info[:address] is always an ip
  #---------------------------------------------------------------------------------------------------------------------
  def get_device_id(ip, site_device_listing)
    site_device_listing.each do |device_info|
      if  device_info[:address] =~ /#{ip}/
        return device_info[:device_id]
      end
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Parse the scan data from Nexpose and load tickets to be created into the DB.
  #
  # ticket_params - The parameters that define a ticket.
  #---------------------------------------------------------------------------------------------------------------------
  def build_and_store_tickets(ticket_params)
    begin
      host = ticket_params[:host]
      scan_id = ticket_params[:scan_id]
      site_id = ticket_params[:site_id]

      nsc_connection = NSCConnectionManager.instance.get_nsc_connection(host)

      report_manager = ReportDataManager.new(nsc_connection)
      data = report_manager.get_raw_xml_for_scan(scan_id)

      # Parse the XML
      raw_xml_report_processor = RawXMLReportProcessor.new
      raw_xml_report_processor.parse(data)

      # The only way to get the corresponding device-id is though mappings
      site_device_listing = nsc_connection.site_device_listing(site_id)

      ticket_data = build_ticket_data(site_device_listing, raw_xml_report_processor.host_data)
      populate_vuln_database(raw_xml_report_processor.vuln_data)

      # Now create each ticket
      ticket_data.each do |ticket|
        ticket_id = build_key(ticket)
        unless (ticket_in_creation_queue?(ticket_id))
          # Add the NSC host address
          ticket[:nsc_host] = host
          TicketsToBeCreated.create(:ticket_id => ticket_id, :ticket_data => ticket)
        end
      end

      # This needs to be the last thing done as it marks successful completion of ticket processing.
      @ticket_processing_queue.delete ticket_params
    rescue Exception => e
      # TODO: Tie in logging
      @logger.add_log_message "[!] Error in build and storage of tickets: #{e.backtrace}"

      # In case of an exception move this ticket to the back of the queue.
      @ticket_processing_queue.delete ticket_params
      @ticket_processing_queue << ticket_params
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Performs ticket creation.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_tickets
    begin
      tickets_created_without_error = true

      ticket_configs = TicketConfig.all
      tickets_to_be_created = load_tickets_to_be_created

      if tickets_to_be_created.empty?
        return
      end

      # We need to first get a list of all the current ticketing modules (ACTIVE OFFCOURSE)
      ticket_configs.each do |ticket_config|
        # Don't process inactive modules
        unless ticket_config.is_active
          next
        end

        # Load rule manager for each config
        rule_manager = RuleManager.new ticket_config.ticket_rule

        # The module name is an integral part of knowing when to ticket
        module_name = ticket_config.module_name

        c = Object.const_get(ticket_config.ticket_client_type.to_s)

        ticket_client_info = TicketClients.find_by_client(c.client_name)
        client_connector = ticket_client_info.client_connector.to_s

        # Initialize the ticket client
        ticket_client = Object.const_get(client_connector).new ticket_config

        tickets_created = 0
        tickets_to_be_created.each do |ticket_data|

          host = ticket_data[:nsc_host]
          ticket_id = ticket_data[:ticket_id]

          # If ticket already created or rules don't match skip
          if (created_already?(host, module_name, ticket_id) || (!rule_manager.matches_rules?(ticket_data)))
            next
          end

          # Decode the proof.
          ticket_data[:proof] = process_db_input_array ticket_data[:proof]

          # Append the ticket configurations
          ticket_data[:ticketing_data] = ticket_config
          ticket_data[:formatter] = ticket_client_info.formatter

          msg = ticket_client.insert_ticket ticket_data

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

  #
  # Creates a ticket key
  #
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

  def ticket_in_creation_queue? ticket_id
    ticket_to_be_created = TicketsToBeCreated.find_by_ticket_id(ticket_id)
    (not ticket_to_be_created.nil?)
  end

  #
  # TODO: This changes when ticket scopes are added
  # @retuns true iff the ticket has already been created for this host, model and ticket_id
  #
  def created_already? host, module_name, ticket_id
    tickets_created = TicketsCreated.find_by_host_and_module_name_and_ticket_id(host, module_name, ticket_id)
    (not tickets_created.nil?)
  end

end
