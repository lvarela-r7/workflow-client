class WorkFlowEngine

  @@initialized = false

  # Start the scan manager and scan poller
  def initialize

    if @@initialized
      return
    else
      @@initialized = true
    end

    # LOAD SINGLETONS
    # This is important because RAILS will drop all references after used
    # thus making singletons useless.
    load_singletons

    # Load unconventionally named libs
    load_libs

    @logger = LogManager.instance
    @logger.add_log_message "[!] Initializing the WorkFlow Engine"

    #init all the nexpose instances
    NSCConnectionManager.instance

    #Starts notification manager
    ScanStartNotificationManager.instance

    #Start scan manager
    ScanManager.instance

    # TODO: Need to develop a way to auto load modules
    TicketManager.instance
    @logger.add_log_message "[*] Loading ticket module"

    ScanSummariesManager.load

=begin
    poll_time = @config.get_value 'poll_time'
    @scan_manager = ScanManager.new  @client_api, false, poll_time

    scan_status_proxy = ScanStartProxy.new @scan_manager
    @scan_start_notifier = ScanStartNotificationManager.new @client_api, poll_time
    @scan_start_notifier.add_observer scan_status_proxy
    @scan_manager.add_observer self

    @ticket_manager = TicketManager.instance @client_api
=end

  end

  @@SINGLETONS = ['logging/log_manager', 'misc/cache', 'modules/ticketing/ticket_manager',
                  'scan/nexpose/scan_manager', 'scan/nexpose/scan_start_notification_manager',
                  'scan/nexpose/scan_history_manager', 'net/nsc_connection_manager']
  def load_singletons
    @@SINGLETONS.each do |singleton|
      require File.expand_path(File.join(File.dirname(__FILE__), singleton))
    end
  end

  @@LIBS = ['eventmachine']
  def load_libs
     @@LIBS.each do |lib|
       require lib
     end
  end

end


# Simply used to pass started scan id's to the scan manager
class ScanStartProxy

  def initialize scan_manager
    @scan_manager = scan_manager
  end

  def update scan_id, scan_info, notifier
    puts "Scan start proxy called"
    @scan_manager.add_scan_observed scan_id
  end
end


