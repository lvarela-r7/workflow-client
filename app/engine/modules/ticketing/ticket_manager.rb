require 'rex/parser/nexpose_xml'
require 'singleton'

#TODO: Separate out parsing into its own module
#TODO: Look into a proper listener model to start the thread
class TicketManager
  include Singleton

  attr_accessor :vuln_map

  public
  ##################
  # PUBLIC METHODS #
  ##################

  #---------------------------------------------------------------------------------------------------------------------
  # Observed scan manager and scan history manager calls into this
  #---------------------------------------------------------------------------------------------------------------------
  def update scan_info
    status = scan_info[:status].to_s
    if (status =~ /finished/i || status =~/stopped/i)
      has_ticket = false
      @ticket_processing_queue.each do |ticket|
        # If this ticket is already in the process queue then don't add.
        if ticket[:scan_id].to_i == scan_info[:scan_id].to_i and ticket[:host].to_s.eql?(scan_info[:host].to_s)
          has_ticket = true
          break
        end
      end

      unless has_ticket
        # TODO: Error checking
        scan_key = scan_info[:host].to_s + scan_info[:scan_id].to_s
        site_id = ScanStartNotificationManager.instance.get_site_id_from_scan_key scan_key
        @ticket_processing_queue << {
            :scan_id => scan_info[:scan_id],
            :site_id => site_id,
            :host => scan_info[:host]
        }
      end
    end
  end

  private
  ##################
  # PRIVATE METHODS#
  ##################

  def initialize
    # An array of scan-id to create tickets from
    @ticket_processing_queue = []

    #
    # TODO: Store this data in the DB 'vuln_data'
    # * vuln_id * vuln_data (serialized data)
    #
    # Maps vuln_id to vuln data

    load_vuln_map

    #TODO: Move to DB (low-low priority)
    @vulnerable_markers = ['vulnerable-exploited', 'vulnerable-version', 'potential']

    # Setup parser
    @host_data = []
    @vuln_data = []

    @parser = Rex::Parser::NexposeXMLStreamParser.new
    @parser.callback = proc { |type, value|
      case type
        when :host
          @host_data << value
        when :vuln
          @vuln_data << value
      end
    }

    @logger = LogManager.instance

    # This poller is fired every 10 seconds, we hard-code this
    start_poller 10

    # Now add self to the scan manager observer list
    ScanManager.instance.add_observer self
  end

  #
  # Bad idea! TODO: Fix
  #
  def load_vuln_map
    vuln_infos = VulnInfo.all
    @vuln_map = {}
    vuln_infos.each do |vuln_info|
      vuln_info.vuln_data[:description] = process_db_input_array vuln_info.vuln_data[:description]
      vuln_info.vuln_data[:solution] = process_db_input_array vuln_info.vuln_data[:solution]

      @vuln_map[vuln_info.vuln_id] = vuln_info.vuln_data
    end
  end

  #
  # This thread sleeps until the queue is empty
  #
  def start_poller sleep_time
    operation = proc {
      @logger.add_log_message '[*] Starting ticket processing thread ...'
      while true do
        begin
          if @ticket_processing_queue.empty?
            sleep sleep_time.to_i
          else
            processing_ticket = @ticket_processing_queue.first

            # Builds the tickets and stores them in the DB
            build_and_store_tickets processing_ticket
          end

          # Call this method regardless to ensure we re-attempt to create failed tickets
          # Actually writes out the tickets to the ticketing client
          handle_tickets
        rescue Exception => e
          @logger.add_log_message "[!] Error in Ticket Manager: #{e.backtrace}"
        end
      end

      @is_poller_thread_running = false
      puts "Poller exiting ..."
    }

    EM.defer operation
  end

  #
  # Returns an array of ticket data:
  #
  # ip - The device IP address
  # device_id
  # name
  # fingerprint - The fingerprint is built from highest certainty
  # vuln_id
  # vuln_status - Vulnerability identifiers: vuln version, potential, etc ...
  # port
  # protocol
  # vkey
  # proof
  # ticket_key
  #
  def build_ticket_data site_device_listing
    begin
      res = []
      @host_data.each do |host_data|
        ip = host_data["addr"]
        device_id = get_device_id ip, site_device_listing

        # Just take the first name
        names = host_data["names"]
        name = ''
        if not names.nil? or not names.empty?
          name = names[0]
        end

        fingerprint = ''
        fingerprint << (host_data["os_vendor"] || '')
        fingerprint << ' '
        fingerprint << (host_data["os_family"] || '')

        host_data["vulns"].each { |vuln_id, vuln_info|
          # Currently only 've' and 'vv' are parsed
          # we will do the status check regardless to
          # ensure we never break
          unless is_vulnerable? vuln_info["status"]
            next
          end

          vkey = vuln_info["key"] || ''
          vuln_endpoint_data = vuln_info["endpoint_data"]

          port = ''
          protocol = ''
          if vuln_endpoint_data
            port = vuln_endpoint_data["port"] || ''
            protocol = vuln_endpoint_data["protocol"] || ''
          end

          # format to avoid weird DB issues
          proof = process_db_input_array vuln_info['proof'], true

          res << {
              :ip => ip,
              :device_id => device_id,
              :name => name,
              :fingerprint => fingerprint,
              :vuln_id => vuln_id,
              :vuln_status => vuln_info["status"],
              :port => port,
              :protocol => protocol,
              :vkey => vkey,
              :proof => proof,
          }
        }
      end
    rescue Exception => e
      @logger.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"
    end

    res
  end

  def populate_vuln_map
    begin
      @vuln_data.each do |vuln_data|
        id = vuln_data["id"].to_s.downcase.chomp
        unless @vuln_map.has_key? id
          begin
            vuln_input_data = {
                :severity => vuln_data["severity"],
                :title => vuln_data["title"],
                :description => vuln_data["description"],
                :solution => vuln_data["solution"],
                :cvss => vuln_data["cvssScore"]
            }
            @vuln_map[id] = vuln_input_data

            # Add to the DB
            # This is needed in
            # Saving this data might be a bad idea
            # Only encode values going into the DB
            description = process_db_input_array vuln_data["description"], true
            solution = process_db_input_array vuln_data["solution"], true
            vuln_input_data[:description] = description
            vuln_input_data[:solution] = solution
            VulnInfo.create(:vuln_id => id, :vuln_data => vuln_input_data)
          rescue Exception => e
            @logger.add_log_message "[!] vulnid: #{id}, vuln data: #{vuln_input_data.inspect}"
            @logger.add_log_message "[!] Error in populating vuln map: #{e.backtrace}"
          end
        end
      end
    end
  end

  def is_vulnerable? id
    @vulnerable_markers.include? id.to_s.chomp
  end

  # TODO: research :address is always an ip
  def get_device_id ip, site_device_listing
    site_device_listing.each do |device_info|
      if  device_info[:address] =~ /#{ip}/
        return device_info[:device_id]
      end
    end
  end

  #
  #
  #
  def build_and_store_tickets ticket_params
    begin
      host = ticket_params[:host]
      scan_id = ticket_params[:scan_id]
      site_id = ticket_params[:site_id]

      nsc_connection = NSCConnectionManager.instance.get_nsc_connection host

      adhoc_report_generator = Nexpose::ReportAdHoc.new nsc_connection
      adhoc_report_generator.addFilter 'scan', scan_id
      data = adhoc_report_generator.generate

      # The only way to get the corresponding device-id is though mappings
      site_device_listing = nsc_connection.site_device_listing site_id

      REXML::Document.parse_stream(data.to_s, @parser)

      ticket_data = build_ticket_data site_device_listing
      populate_vuln_map

      # Now create each ticket
      ticket_data.each do |ticket|
        ticket_id = build_key ticket
        unless ticket_in_creation_queue? ticket_id
          # Add the NSC host address
          ticket[:nsc_host] = host
          TicketsToBeCreated.create(:ticket_id => ticket_id, :ticket_data => ticket)
        end
      end

      # Clear data after processing
      @host_data = []
      @vuln_data = []
      @ticket_processing_queue.delete ticket_params
    rescue Exception => e
      @logger.add_log_message "[!] Error in build and storage of tickets: #{e.backtrace}"
    end
  end

  #
  #
  #
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

        ticket_client_info = TicketClients.find_by_client(Object.const_get(ticket_config.ticket_client_type.to_s).client_name)
        client_connector = ticket_client_info.client_connector.to_s

        # Initialize the ticket client
        ticket_client = Object.const_get(client_connector).new ticket_config

        tickets_created = 0
        tickets_to_be_created.each do |ticket_data|

          host = ticket_data[:nsc_host]
          ticket_id = ticket_data[:ticket_id]

          # If ticket already created or rules don't match skip
          if created_already?(host, module_name, ticket_id) or not rule_manager.matches_rules? ticket_data
            next
          end

          # Decode the proof.
          ticket_data[:proof] = process_db_input_array ticket_data[:proof]

          # Append the ticket configurations
          ticket_data[:ticketing_data] = ticket_config
          ticket_data[:formatter] = ticket_client_info.formatter

          msg = ticket_client.insert_ticket ticket_data
          if msg
            @logger.add_log_message "[!] Ticketing error: #{msg}"
            tickets_created_without_error = false
            break
          else
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
  def build_key ticket
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

  #
  # Reads in tickets to be created and converts to array of hash
  #
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

  #
  #
  #
  def process_db_input_array proof, encode=false
    begin
      if encode
        encoded_string = ""
        proof.each do |p|
          output = p.to_s
          output.squeeze!
          output.gsub!(/[\r\n\t]/, '\r' => '', '\n' => '', '\t' => '')
          output.chomp!
          unless output.empty?
            if encoded_string.length > 0
              encoded_string << "||"
            end
            encoded_string << output
          end
        end
        encoded_string
      else
        decoded_string = proof.split("||")
        decoded_string
      end
    rescue Exception => e
      @logger.add_log_message "[!] Error in processing DB input array: #{e.backtrace}"
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