#---------------------------------------------------------------------------------------------------------------------
# == Synopsis
# All classes that requires separate threads to perform some sort of monitoring operation should use this class.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#---------------------------------------------------------------------------------------------------------------------
class Poller

  #---------------------------------------------------------------------------------------------------------------------
  # Starts the polling process
  #
  # @param method_name - The symbolized method name to be called periodically
  # @param period_key - The name of the key to lookup in the DB to find the period
  # @param poller_thread_name - The name of the thread
  #---------------------------------------------------------------------------------------------------------------------
  def start_poller period_key, poller_thread_name, method_name=:process
    @logger = LogManager.instance
    operation = proc {
      @logger.add_log_message "[*] #{poller_thread_name} poller thread executing ..."
      while true do
        begin
          update_poller_frequency(period_key, poller_thread_name)
          sleep @period
          self.send method_name

        # Don't allow poller to die
        rescue Exception => e
          @logger.add_log_message "[!] Error in #{poller_thread_name}: #{e.message}"
        end
      end

      @logger.add_log_message "[-] #{poller_thread_name} poller thread exiting ..."
    }

    EM.defer operation
  end

  private
  ###################
  # PRIVATE METHODS #
  ###################

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
