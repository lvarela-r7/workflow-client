#
# Only ran once on startup
# TODO: Maybe add thread to run every hour
#
class ScanSummariesManager

  #---------------------------------------------------------------------------------------------------------------------
  # Updates the scan summary table on startup.
  # First grabs all the nsc_connections.
  # Check to see if for the given scan ID and host if the data already exists.
  # If not get all the data for that host
  # Stops upon exception - The only way to know when we have reached out last ID
  #---------------------------------------------------------------------------------------------------------------------
  def ScanSummariesManager.load
    NSCConnectionManager.instance.get_nsc_connections.each do |host, wrapped_connection|
      load_by_host(host, wrapped_connection)
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Used to update added nexpose hosts
  #---------------------------------------------------------------------------------------------------------------------
  def ScanSummariesManager.load_by_host host, wrapped_connection
    logger = LogManager.instance
    scan_id = 0
    loop do
      scan_id+=1

      # Does this value exist in the database
      if ScanSummary.find_by_host_and_scan_id(host.to_s.chomp, scan_id)
        next
      end

      begin
        scan_stats = wrapped_connection.scan_statistics(scan_id)
        # A null value can also signal the last know scan
        # this might be bad as scan IDs are determined by
        # the database and might not be serial.
        unless scan_stats
          break
        end
      rescue Exception
        # Only way to signal last scan ID
        break
      end

      summaries = scan_stats[:summary]
      status = summaries['status']
      if status =~ /finished|stopped/
        start_time = Util.parse_utc_time(summaries["startTime"])
        end_time = Util.parse_utc_time(summaries["endTime"])

        unless (start_time || end_time)
          logger..add_log_message("[-] There was a problem parsing scan times: start: #{summaries['startTime']}" +
                                      " end:  #{summaries['endTime']}")
          next
        end
        ScanSummary.create(:host => host, :scan_id => scan_id, :site_id => summaries["site-id"],
                           :start_time => start_time, :end_time => end_time, :status => status)
      end
    end
  end

end