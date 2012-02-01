class Poller

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def start_poller method_name, period_key, poller_thread_name
    @logger = LogManager.instance
    operation = proc {
      @logger.add_log_message "[*] #{poller_thread_name} poller thread executing ..."
      begin
        while true do
          update_poller_frequency period_key, poller_thread_name
          sleep @period
          self.send method_name
        end
      rescue Exception => e
        @logger.add_log_message "[!] Error in #{poller_thread_name}: #{e.message}"
        raise e
      end
      @logger.add_log_message "[-] #{poller_thread_name} poller thread exiting ..."
    }

    EM.defer operation
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def update_poller_frequency period_key, poller_thread_name
    while true
      begin
        # Weird initialization bug with RAILS where it hasn't loaded this class yet.
        changed_period = IntegerProperty.find_by_property_key(period_key.to_s).property_value
        break
      rescue Exception
        next
      end
    end
    unless @period
      @period = changed_period
      return
    end

    if (@period != changed_period)
       @period = changed_period
       @logger.add_log_message "[*] #{poller_thread_name} poller period is updated to #{@period.to_s} seconds"
    end
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def method_missing method_name, *args
    # TODO: Move this to a proper logger
    @logger.add_log_message "[!] Invalid method called: #{method_name}"
  end

end
