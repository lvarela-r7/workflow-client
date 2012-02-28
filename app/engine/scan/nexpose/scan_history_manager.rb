#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# This class is used to find the latest scans per site that falls within the user configured
# time period.  These scans are then passed into the main ticketing system.
#
# == ALORITHM DEFINITION:
# Gather from the scan summaries table all the scans that fall within the defined time frame.
# and ships them off to the obervers, it is up to the obeserver to determine if the data was
# already processed in the context needed, this class was not meant to have much logic built in.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

require 'observer'
require 'singleton'

class ScanHistoryManager < Poller
  include Observable
  include Singleton

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    # A map of
    @site_last_scanned = {}
    @nsc_conn_manager = NSCConnectionManager.instance
    @logger = LogManager.instance
    start_poller('scan_history_poll_period', 'Scan History Manager')
  end

  private
  ###################
  # PRIVATE METHODS #
  ###################

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def process
    set_time_range
    scans_to_process = ScanSummary.all(:conditions => ['end_time >= ?', @time_range])
    scans_to_process.each do |scan_data|
      content = {
          :scan_id => scan_data[:scan_id],
          :status => scan_data[:status],
          :message => nil,
          :host => scan_data[:host]
      }

      #Notify Observers
      changed
      notify_observers content
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Defines how far back to process scans from.
  #---------------------------------------------------------------------------------------------------------------------
  def set_time_range
    time_frame_id = IntegerProperty.find_by_property_key('scan_history_polling_time_frame').property_value
    polling_value = IntegerProperty.find_by_property_key('scan_history_polling').property_value
    @time_range = Time.now - (ScanHistoryTimeFrame.find_by_id(time_frame_id).multiplicate * polling_value)
    @logger.add_log_message "[*] Scans will be processed from #{@time_range.to_s}"
  end

end