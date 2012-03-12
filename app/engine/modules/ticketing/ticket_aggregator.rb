#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Build up all the data needed to process a ticket.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

class TicketAggregator

  public
  ######################################################################################################################
  # PUBLIC METHODS                                                                                                     #
  ######################################################################################################################

  #---------------------------------------------------------------------------------------------------------------------
  # Initializes the log manager.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    @logger = LogManager.instance

    # 3 vulnerable states
    @vulnerable_markers = %w(vulnerable-exploited vulnerable-version potential)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Parse the scan data from Nexpose and load tickets to be created into the DB.
  #
  # ticket_params - The parameters that define a ticket.
  #---------------------------------------------------------------------------------------------------------------------
  def build_and_store_tickets(ticket_params)
    host = ticket_params[:host]
    scan_id = ticket_params[:scan_id]
    site_id = ticket_params[:site_id]

    nsc_connection = NSCConnectionManager.instance.get_nsc_connection(host)

    # Load and parse the XML report for the particular scan-id
    report_manager = ReportDataManager.new(nsc_connection)
    data = report_manager.get_raw_xml_for_scan(scan_id)
    raw_xml_report_processor = RawXMLReportProcessor.new
    raw_xml_report_processor.parse(data)

    # The only way to get the corresponding device-id is though mappings
    site_device_listing = nsc_connection.site_device_listing(site_id)

    # Tickets are built on a per module basis
    ticket_configs = TicketConfig.all
    ticket_configs.each do |ticket_config|
      # Don't process inactive modules
      next unless ticket_config.is_active

      ticket_scope_id = ticket_config.ticket_scope.id

      # The module name is an integral part of knowing when to ticket
      module_name = ticket_config.module_name

      # Check if this scan has already been processed for this module.
      # And if the module does not support updates
      next if ScansProcessed.where(:host => ticket_params[:host],
                                   :scan_id => ticket_params[:scan_id],
                                   :module => module_name).exists? and !ticket_config.supports_updates

      case ticket_scope_id
        when 1
          ticket_data = VulnDeviceScope.build_ticket_data(site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        when 2
          ticket_data = DeviceScope.build_ticket_data(site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        when 3
          ticket_data = VulnScope.build_ticket_data(site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        else
          raise "Invalid ticket scope encountered #{ticket_scope_id}"
      end

      # Now create each ticket
      ticket_data.each do |ticket|
        ticket_id = ticket[:ticket_id]
        unless ticket_in_creation_queue?(ticket_id)
          # Add the NSC host address
          ticket[:nsc_host] = host
          TicketsToBeProcessed.create(:ticket_id => ticket_id, :ticket_data => ticket)
        end
      end

      ScansProcessed.create(:scan_id => scan_id, :host => host, :module => module_name)
    end

    # This needs to be the last thing done as it marks successful completion of ticket processing.
    TicketManager.instance.get_ticket_processing_queue.delete ticket_params
  rescue Exception => e
    # TODO: Tie in actually logging and move this to that
    @logger.add_log_message "[!] Error in build and storage of tickets: #{e.backtrace}"

    # In case of an exception move this ticket to the back of the queue.
    TicketManager.instance.get_ticket_processing_queue.delete ticket_params
    TicketManager.instance.get_ticket_processing_queue << ticket_params
  end

  private
  ######################################################################################################################
  # PRIVATE METHODS                                                                                                    #
  ######################################################################################################################

  #---------------------------------------------------------------------------------------------------------------------
  # Returns an array of ticket data:
  #
  #   db_op - The database operation to perform: (INSERT, UPDATE, DELETE)
  #
  #   CREATE:
  #     ip - The device IP address
  #     device_id
  #     name
  #     fingerprint - The fingerprint is built from highest certainty
  #     vuln_id
  #     vuln_status - Vulnerability identifiers: vuln version, potential, etc ...
  #     port
  #     protocol
  #     vkey
  #     proof
  #     ticket_key
  #
  #    UPDATE:
  #      update_data is provided (ie: {:update_data => {:data => (), :update_obj => ())}})
  #
  #    DELETE:
  #      delete_key is returned (ie: :remote_key => key)
  #
  # site_device_listing - Used to do device ID lookup
  # host_data_array - Parsed host data
  # ticket_config -
  #
  #---------------------------------------------------------------------------------------------------------------------
  def build_ticket_data(site_device_listing, host_data_array, ticket_config)
    res = []

    # Load rule manager for each config
    rule_manager = RuleManager.new(ticket_config.ticket_rule)

    # Need to set the client_connector as part of the data returned
    c = Object.const_get(ticket_config.ticket_client_type.to_s)
    ticket_client_info = TicketClients.find_by_client(c.client_name)
    client_connector = ticket_client_info.client_connector.to_s

    # Need to set the formatter too
    formatter = ticket_client_info.formatter

    host_data_array.each do |host_data|
      ip = host_data['addr']
      names = host_data['names']
      device_id = get_device_id(ip, site_device_listing)

      # Just take the first name
      # TODO: Think about this more
      name = ''
      name = names[0] if !names.nil? || !names.empty?

      fingerprint = ''
      fingerprint << (host_data['os_vendor'] || '')
      fingerprint << ' '
      fingerprint << (host_data['os_family'] || '')

      host_data['vulns'].each { |vuln_id, vuln_info|
        vuln_status = vuln_info['status']

        # To support closed loop ticketing we need all tests
        # next unless is_vulnerable?(vuln_status)

        vkey = (vuln_info['key'] || '')
        vuln_endpoint_data = vuln_info['endpoint_data']

        port = ''
        protocol = ''
        if vuln_endpoint_data
          port = (vuln_endpoint_data['port'] || '')
          protocol = (vuln_endpoint_data['protocol'] || '')
        end

        # Format to avoid weird DB issues
        proof = Util.process_db_input_array(vuln_info['proof'], true)

        ticket_data = {
            :ip => ip,
            :device_id => device_id,
            :name => name,
            :fingerprint => fingerprint,
            :vuln_id => vuln_id,
            :vuln_status => vuln_status,
            :port => port,
            :protocol => protocol,
            :vkey => vkey,
            :proof => proof,
            :formatter => formatter,
            :client_connector => client_connector,
            :module => module_name
        }

        if rule_manager.passes_rules?(ticket_data)
          res << ticket_data
        end
      }
    end

    res
  rescue Exception => e
    @logger.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets whether or not this ticket is already in the creation queue
  #---------------------------------------------------------------------------------------------------------------------
  def ticket_in_creation_queue?(ticket_id)
    ticket_to_be_created = TicketsToBeProcessed.find_by_ticket_id(ticket_id)
    (not ticket_to_be_created.nil?)
  end



  #---------------------------------------------------------------------------------------------------------------------
  # Ensure the vulnerability status defines a vulnerable threat.
  #---------------------------------------------------------------------------------------------------------------------
  def is_vulnerable?(vuln_status)
    @vulnerable_markers.include?(vuln_status.to_s.chomp)
  end

end