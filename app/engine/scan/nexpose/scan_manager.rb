#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Used to start site device scans where a user is able to specify the maximum amount of scans that
# should be running at a time.  This class does not guarantee that there will be no more than the
# maximum amount of scans specified will be running BUT scans will not be started from this class
# until the current amount of scans running is less than or equal to the maximum.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

require 'observer'
require 'singleton'

class ScanManager
  include Singleton
  include Observable

  # Determines how often the poller thread is executed
  attr_reader :period

  # Synchronize calls that modify open data structs
  @semaphore = nil

  # A Hash of scan-ids to an array of operations for that scan
  # All tasks associated with a scan id must implement #scan_update
  @conditional_device_scans = nil
  @excution_cycle_started = nil
  @poler_exit_on_completion = nil

  #
  #
  #
  def start_poller
    operation = proc {
      @logger.add_log_message "[*] Scan Manager poller thread executing ..."
      begin
        while true do
          sleep @period
          # Check if there are modules
          # If not then do not execute this block
          check_and_execute_op
        end
      rescue Exception => e
        @logger.add_log_message "[!] Error in Scan Manager: #{e.message}"
      end
      @logger.add_log_message "[-] Scan Manager poller thread exiting ..."
    }

    EM.defer operation
  end

  #
  #
  #
  def check_and_execute_op
    @semaphore.synchronize do

      @scans_observed.keys.each do |host|
        @scans_observed[host].each do |scan_id|
          nexpose_connection = NSCConnectionManager.instance.get_nsc_connection host
          status = nexpose_connection.scan_status scan_id
          scan_stats = nexpose_connection.scan_statistics scan_id
          message = scan_stats[:message]

          content = {
              :scan_id => scan_id,
              :status => status,
              :message => message,
              :host => host
          }

          #Notify Observers
          changed
          notify_observers content

          # Removed scans that are in a static state
          if status =~ /finished/ or status =~ /stopped/ or status =~ /paused/
            @logger.add_log_message "[-] Scan #{scan_id} is #{status}!"
            @scans_observed[host].delete scan_id
          end
        end
      end

    end # End of synchronize block
  end

  public

  #
  # The poller thread used within this class is initialized here.
  #
  # period: The frequency at which the poller thread executes
  #
  def initialize
    @logger = LogManager.instance
    @period = IntegerProperty.find_by_property_key('nsc_polling').property_value
    @semaphore = Mutex.new
    @scans_observed = {}
    start_poller

    # Add self as observer to scan start manager
    ScanStartNotificationManager.instance.add_observer self
  end

  #
  # Adds a scan to be observed
  # scan_id: The ID of the scan to be observed.
  #
  def add_scan_observed scan_id, host
    @logger.add_log_message "[+] Observing scan \"#{scan_id}\" at \"#{host}\""
    if @scans_observed[host]
      @scans_observed[host] << scan_id
    else
      @scans_observed[host] = []
      @scans_observed[host] << scan_id
    end
  end

  #
  # Removes a currently observed scan
  # scan_id: The ID of the scan to be removed.
  #
  def remover_scan_observed scan_id, host
    @scans_observed[host].delete scan_id
  end

  #
  # Notification block
  #
  def update scan_info
    add_scan_observed scan_info[:scan_id], scan_info[:host]
  end

  def update_poller_frequency new_period
    @period = new_period
    @logger.add_log_message "[*] Scan Manager poller period is updated to #{@period.to_s} seconds"
  end
end