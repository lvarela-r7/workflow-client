#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Build up all the data needed to process a ticket.
# TODO: Update the scopes to handle tickets in the processing queue.
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
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Parse the scan data from Nexpose and load tickets to be created into the DB.
  #
  # ticket_params - The parameters that define a ticket.
  #---------------------------------------------------------------------------------------------------------------------
  def build_and_store_tickets(ticket_params)
    nexpose_host = ticket_params[:host]
    scan_id = ticket_params[:scan_id]
    site_id = ticket_params[:site_id]

    nsc_connection = NSCConnectionManager.instance.get_nsc_connection(nexpose_host)

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

      p ticket_params.inspect

      ticket_scope_id = ticket_config.scope_id
      #hardcode ticketing scope for now, since the above line was failing
      #ticket_scope_id = 1

      # The module name is an integral part of knowing when to ticket
      module_name = ticket_config.module_name

      # Check if this scan has already been processed for this module.

      next if ScansProcessed.where(:host => nexpose_host,
                                   :scan_id => ticket_params[:scan_id].to_s, 
                                   :module => module_name).exists?

      case ticket_scope_id
        when 1
          p "Using ticket per vuln per device scope."
          ticket_data = VulnDeviceScope.build_ticket_data(nexpose_host, site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        when 2
          p "Using ticket per device scope."
          ticket_data = DeviceScope.build_ticket_data(site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        when 3
          p "Using ticket per vuln scope."
          ticket_data = VulnScope.build_ticket_data(site_device_listing, raw_xml_report_processor.host_data, ticket_config)
        else
          raise "Invalid ticket scope encountered #{ticket_scope_id}"
      end

      # Now create each ticket
      ticket_data.each do |ticket|
        ticket_id = ticket[:ticket_id]
        unless ticket_in_creation_queue?(ticket_id)
          # Add the NSC host address
          ticket[:nsc_host] = nexpose_host
          ticket[:ticket_config] = ticket_config
          TicketsToBeProcessed.create(:ticket_id => ticket_id, :ticket_data => ticket)
        end
      end

      ScansProcessed.create(:scan_id => scan_id, :host => nexpose_host, :module => module_name)
    end

    # This needs to be the last thing done as it marks successful completion of ticket processing.
    TicketManager.instance.get_ticket_processing_queue.delete(ticket_params)
  rescue Exception => e
    p e.message
    p e.backtrace
    # TODO: Tie in actually logging and move this to that
    @logger.add_log_message "[!] Error in build and storage of tickets: #{e.backtrace}"

    # In case of an exception move this ticket to the back of the queue.
    TicketManager.instance.get_ticket_processing_queue.delete(ticket_params)
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


  #---------------------------------------------------------------------------------------------------------------------
  # Gets whether or not this ticket is already in the creation queue
  #---------------------------------------------------------------------------------------------------------------------
  def ticket_in_creation_queue?(ticket_id)
    ticket_to_be_created = TicketsToBeProcessed.find_by_ticket_id(ticket_id)
    (not ticket_to_be_created.nil?)
  end

end
