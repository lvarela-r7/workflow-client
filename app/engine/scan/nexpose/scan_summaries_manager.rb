#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Updates the scan summaries table for completed (stopped/finished) scans.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

require 'singleton'

class ScanSummariesManager
  include Singleton

  #---------------------------------------------------------------------------------------------------------------------
  # Initializes logger, and adds self as an observer of the scan manager class.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    @logger = LogManager.instance
    ScanManager.instance.add_observer self
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Observed objects call into this method.
  #
  # scan_info -
  #---------------------------------------------------------------------------------------------------------------------
  def update(scan_info)
    status = scan_info[:status].to_s
    if status =~ /finished/i || status =~/stopped/i
       host = scan_info[:host]
       nsc_conn = NSCConnectionManager.instance.get_nsc_connection(host)
       scan_id = scan_info[:scan_id]
       load_by_host_and_scan_id(host, nsc_conn, scan_id)
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Updates the scan summary table on startup.
  # First grabs all the nsc_connections.
  # Check to see if for the given scan ID and host if the data already exists.
  # If not get all the data for that host
  # Stops upon exception - The only way to know when we have reached out last ID
  #---------------------------------------------------------------------------------------------------------------------
  def load
    NSCConnectionManager.instance.get_nsc_connections.each do |host, wrapped_connection|
      load_by_host(host, wrapped_connection)
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Used to update added nexpose hosts
  #---------------------------------------------------------------------------------------------------------------------
  def load_by_host(host, wrapped_connection)
    scan_id = 0
    loop do
      scan_id+=1
      break if load_by_host_and_scan_id(host, wrapped_connection, scan_id)
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Used to update added nexpose hosts
  #
  # @returns true if the control should break out.
  #---------------------------------------------------------------------------------------------------------------------
  def load_by_host_and_scan_id(host, wrapped_connection, scan_id)
    # For all calls do not log error messages.
    wrapped_connection.log_errors = false

    begin
      # Does this value exist in the database
      false if ScanSummary.find_by_host_and_scan_id(host.to_s.chomp, scan_id)

      begin
        scan_stats = wrapped_connection.scan_statistics(scan_id)
        # A null value can also signal the last know scan
        # this might be bad as scan IDs are determined by
        # the database and might not be serial.
        true unless scan_stats
      rescue Exception
        # Only way to signal last scan ID
        return true
      end

      summaries = scan_stats[:summary]
      status = summaries['status']
      if status =~ /finished|stopped/
        start_time = Util.parse_utc_time(summaries["startTime"])
        end_time = Util.parse_utc_time(summaries["endTime"])

        unless start_time || end_time
          @logger..add_log_message("[-] There was a problem parsing scan times: start: #{summaries['startTime']}" +
                                       " end:  #{summaries['endTime']}")
          return false
        end
        ScanSummary.create(:host => host, :scan_id => scan_id, :site_id => summaries["site-id"],
                           :start_time => start_time, :end_time => end_time, :status => status)
      end

      false
    ensure
      # Be sure to set the connection to always log errors
      wrapped_connection.log_errors = true
    end
  end

end