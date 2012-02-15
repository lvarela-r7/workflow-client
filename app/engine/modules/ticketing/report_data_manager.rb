#-----------------------------------------------------------------------------------------------------------------------
# Provides a more robust mechanism to retrieve Nexpose raw xml report.
# TODO: refactor to be more generic
#-----------------------------------------------------------------------------------------------------------------------
class ReportDataManager

  #---------------------------------------------------------------------------------------------------------------------
  # Sets the nexpose connection object
  #---------------------------------------------------------------------------------------------------------------------
  def initialize(nsc_connection)
    @nsc_connection = nsc_connection
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml
  #---------------------------------------------------------------------------------------------------------------------
  def get_raw_xml_for_scan(scan_id)
    data = nil
    ad_hoc_retrieved = false
    begin
      data = get_adhoc_for_scan(scan_id)
      ad_hoc_retrieved = true
    rescue
      # do nothing
    end

    # If adhoc fails fall back on disk generation.
    unless (ad_hoc_retrieved)
      data = get_on_disk_report_for_scan(scan_id)
    end

    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml via the adhoc mechanism
  #---------------------------------------------------------------------------------------------------------------------
  def get_adhoc_for_scan(scan_id)
    adhoc_report_generator = Nexpose::ReportAdHoc.new(@nsc_connection)
    adhoc_report_generator.addFilter('scan', scan_id)
    data = adhoc_report_generator.generate
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml by generating the report on disk then pulling it across
  #---------------------------------------------------------------------------------------------------------------------
  def get_on_disk_report_for_scan(scan_id)
    data = nil
    report_config_name = "nexflow_report_config_#{scan_id}"
    report = Nexpose::ReportConfig.new(@nsc_connection)
    report.set_name(report_config_name)
    report.addFilter("scan", scan_id)
    report.set_storeOnServer(1)
    report.set_format("raw-xml")

    report.saveReport()

    begin
      url = nil
      while (!url)
        url = @nsc_connection.report_last(report.config_id)
        sleep(2)
      end

      last_data_file_size = 0
      max_interval = 30
      count = 0
      while (true)
        data = @nsc_connection.download(url) rescue nil
        if (data)
          current_file_size = data.length
          if (current_file_size > last_data_file_size)
            last_data_file_size = current_file_size
            count = 0
          else
            if (count > max_interval)
              break
            end
            count += 1
          end

          # Validate report completion
          if (data.index("<NexposeReport") and data.index("</NexposeReport>"))
            break
          end
        else
          if (count > max_interval)
            break
          end
          count += 1
        end
        sleep(1)
      end

    ensure
      begin
        @nsc_connection.report_config_delete(report.config_id)
      rescue
        # TODO: Add log message
        # "Unable to remove report config, please removed config manually #{report.config_id}"
      end
    end

    data
  end

end