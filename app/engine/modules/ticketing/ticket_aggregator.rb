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

    ticket_data = build_ticket_data(site_device_listing, raw_xml_report_processor.host_data)

    # Now create each ticket
    ticket_data.each do |ticket|
      ticket_id = build_key(ticket)
      unless ticket_in_creation_queue?(ticket_id)
        # Add the NSC host address
        ticket[:nsc_host] = host
        TicketsToBeProcessed.create(:ticket_id => ticket_id, :ticket_data => ticket)
      end
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
  #      delete_key is returned (ie: :delete_key => key)
  #
  # site_device_listing - Used to do device ID lookup
  # host_data_array - Parsed host data
  #
  #---------------------------------------------------------------------------------------------------------------------
  def build_ticket_data(site_device_listing, host_data_array)
    begin
      res = []
      host_data_array.each do |host_data|
        ip          = host_data['addr']
        names       = host_data['names']
        device_id   = get_device_id(ip, site_device_listing)

        # Just take the first name
        name = ''
        name = names[0] if !names.nil? || !names.empty?

        fingerprint = ''
        fingerprint << (host_data['os_vendor'] || '')
        fingerprint << ' '
        fingerprint << (host_data['os_family'] || '')

        host_data['vulns'].each { |vuln_id, vuln_info|
          vuln_status = vuln_info['status']

          next unless is_vulnerable?(vuln_status)

          vkey = (vuln_info['key'] || '')
          vuln_endpoint_data = vuln_info['endpoint_data']

          port     = ''
          protocol = ''
          if vuln_endpoint_data
            port     = (vuln_endpoint_data['port'] || '')
            protocol = (vuln_endpoint_data['protocol'] || '')
          end

          # Format to avoid weird DB issues
          proof = Util.process_db_input_array(vuln_info['proof'], true)

          res << {
              :ip          => ip,
              :device_id   => device_id,
              :name        => name,
              :fingerprint => fingerprint,
              :vuln_id     => vuln_id,
              :vuln_status => vuln_status,
              :port        => port,
              :protocol    => protocol,
              :vkey        => vkey,
              :proof       => proof
          }
        }
      end
    rescue Exception => e
      @logger.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"
    end

    res
  end
end