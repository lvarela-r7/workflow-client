#------------------------------------------------------------------------------------------------------
# Used to  update listeners when scans are started
# The update method for observers returns: scan_id and scan_info(:site_id, engine_id, :status
# and :start_time)
# TODO: Handle Idempotency
#------------------------------------------------------------------------------------------------------

require 'observer'
require 'singleton'

class ScanStartNotificationManager < Poller
  include Observable
  include Singleton

  def process
    @semaphore.synchronize {

      if count_observers < 1
        return
      end

      # Get all the NSC connections
      nsc_connections = @nsc_conn_manager.get_nsc_connections
      nsc_connections.keys.each do |host|
        nexpose_connection = nsc_connections[host]
        scan_activities = nexpose_connection.scan_activity
        #TODO: Need to actually ensure the status is running
        #TODO: Add as a listener to scan manager
        #TODO: Make net singletons

        # This is necessary and should be done everywhere a Nexpose API call can fail
        if scan_activities
          scan_activities.each do |scan_activity|
            scan_id = scan_activity[:scan_id]
            scan_key = host.to_s + scan_id.to_s
            if not @running_scans.has_key? scan_key
              scan_info =
                  {
                      :site_id => scan_activity[:site_id],
                      :engine_id => scan_activity[:engine_id],
                      :status => scan_activity[:status],
                      :start_time => scan_activity[:start_time],
                      :scan_id => scan_id,
                      :host => host
                  }

              @running_scans[scan_key] = scan_info
              @logger.add_log_message "[+] Scan with ID #{scan_id} started for site #{scan_activity[:site_id]} on \"#{host}\" "
              changed
              notify_observers scan_info
            end
          end
        end
      end
    }
  end

  public
  def initialize
    @logger = LogManager.instance
    @nsc_conn_manager = NSCConnectionManager.instance
    @running_scans = {}
    @listeners = []
    @semaphore = Mutex.new
    start_poller('nsc_polling', 'Scan Start Manager')
  end

  #------------------------------------------------
  # DEPRECATED
  # The scan key is a combination of host + scan_id
  #------------------------------------------------
  def get_site_id_from_scan_key(scan_key)
    scan_data = @running_scans[scan_key]
    unless scan_data
      raise "No matching site found for #{scan_id}"
    end

    scan_data[:site_id]
  end

end