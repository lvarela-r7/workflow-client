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

  #--------------------------------------------------------------------------------------------------------------------
  # Returns the ticket processing queue.
  #--------------------------------------------------------------------------------------------------------------------
  def get_ticket_processing_queue
    @ticket_processing_queue
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Observed scan managers update this class with scan details here.
  #
  # scan_info - Hash that contains: (:scan_id, :status, :message, :host)
  #---------------------------------------------------------------------------------------------------------------------
  def update(scan_info)
    p "In the update call..."
    p scan_info.inspect

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
    @ticket_aggregator.build_and_store_tickets(ticket_to_be_processed) if ticket_to_be_processed

    # Call this method regardless to ensure we re-attempt to create failed tickets
    # Actually writes out the tickets to the ticketing client
    handle_tickets
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

    p "In get_device_id"


    site_device_listing.each do |device_info|

      device_info[:device_id] if  device_info[:address] =~ /#{ip}/
    end
  end


  #---------------------------------------------------------------------------------------------------------------------
  # Performs ticket processing.
  #---------------------------------------------------------------------------------------------------------------------
  def handle_tickets

    p "Handling tickets..."

    query = 'SELECT id FROM tickets_to_be_processeds'
    ticket_to_be_processed_ids = TicketsToBeProcessed.find_by_sql(query)

    return if not ticket_to_be_processed_ids or ticket_to_be_processed_ids.empty?

    ticket_to_be_processed_ids.each do |ticket_to_be_processed_id|
      begin
        ticket_to_be_processed = TicketsToBeProcessed.find(ticket_to_be_processed_id)
        # There have been too many failed attempts to create this ticket.
        next if ticket_to_be_processed.pending_requeue

        ticket_data = ticket_to_be_processed.ticket_data
        ticket_id = ticket_to_be_processed.ticket_id

        # Initialize the ticket client
        client_connector = ticket_data[:client_connector].to_s
        ticket_client = Object.const_get(client_connector).new(ticket_data)

        host = ticket_data[:nsc_host]

        # Decode the proof.
        ticket_data[:proof] = Util.process_db_input_array(ticket_data[:proof])

        worked = false
        case ticket_data[:ticket_op]
          when :CREATE
            worked = ticket_client.create_ticket(ticket_data)
          when :UPDATE
            worked = ticket_client.update_ticket(ticket_data)
          when :CLOSE
            worked = ticket_client.close_ticket(ticket_data)
          else
            raise "Invalid ticket operation: #{ticket_data[:ticket_op]}"
        end

        if !worked
          raise "Could not create JIRA ticket."
        else
          # Add ticket as already created
          TicketsCreated.create(:ticket_id => ticket_id)
          ticket_to_be_processed.destroy
        end

      rescue Exception => e
        p e.inspect
        p e.message
        p e.backtrace
        failed_attempts = ticket_to_be_processed.failed_attempt_count
        if failed_attempts > IntegerProperty.find_by_property_key('max_ticketing_attempts').property_value
          ticket_to_be_processed.failed_message = e.message
          ticket_to_be_processed.pending_requeue = true
        else
          ticket_to_be_processed.failed_attempt_count = (failed_attempts + 1)
        end
        ticket_to_be_processed.save
      end
    end
  end
end
