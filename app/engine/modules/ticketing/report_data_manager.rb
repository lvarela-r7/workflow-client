#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Provides a more robust mechanism to retrieve Nexpose raw xml report.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
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

    while !ad_hoc_retrieved
      begin
        data = get_adhoc_for_scan(scan_id)
        ad_hoc_retrieved = true
      rescue Exception => e
        p e.message
        p e.backtrace
      end
    end

#    p "trying new method"
    # If adhoc fails fall back on disk generation.
#    data = get_on_disk_report_for_scan(scan_id) 
#    p data.to_s.inspect
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml via the adhoc mechanism
  #---------------------------------------------------------------------------------------------------------------------
  def get_adhoc_for_scan(scan_id)
    adhoc_report_generator = Nexpose::ReportAdHoc.new(@nsc_connection)
    adhoc_report_generator.addFilter('scan', scan_id)

    data = adhoc_report_generator.generate

    while data.to_s.length < 91
      data = adhoc_report_generator.generate
    end

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
    report.set_format("raw-xml-v2")

    begin
      resp = report.saveReport()
    rescue Exception => e
      p e.message
      p e.backtrace
    end

    begin
      url = nil

      while !url
        url = @nsc_connection.report_last(report.config_id)
        sleep(2)
      end

      last_data_file_size = 0
      max_interval = 30
      count = 0

      while true
        while !data
          begin
            data = @nsc_connection.download(url)
          rescue Exception => e
            p e.message
            p e.backtrace
            data = nil
          end
        end

        if data
          current_file_size = data.length
          if current_file_size > last_data_file_size
            last_data_file_size = current_file_size
            count = 0
          else
            if count > max_interval
              break
            end
            count += 1
          end

          # Validate report completion
          if data.index("<NexposeReport") and data.index("</NexposeReport>")
            break
          end
        else
          if count > max_interval
            break
          end
          count += 1
        end
        sleep(1)
      end
    rescue Exception => e
      p e.message
      p e.backtrace
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
