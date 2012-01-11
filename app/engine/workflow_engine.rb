require 'rubygems'
require 'active_record'
require File.expand_path(File.join(File.dirname(__FILE__), 'scan/scan_manager'))
require File.expand_path(File.join(File.dirname(__FILE__), 'scan/scan_start_notification_manager'))
require File.expand_path(File.join(File.dirname(__FILE__), 'net/nsc_conn_manager'))
require File.expand_path(File.join(File.dirname(__FILE__), 'logging/log_manager'))
require File.expand_path(File.join(File.dirname(__FILE__), 'modules/ticketing/ticket_manager'))

class WorkFlowEngine

  @@initialized = false

  # Start the scan manager and scan poller
  def initialize

    if @@initialized
      return
    else
      @@initialized = true
    end

    @logger = LogManager.instance
    @logger.add_log_message "[!] Initializing the WorkFlow Engine"
    @nsc_conn_manager = NSCConnectionManager.instance
    nsc_configs = NscConfig.all

    added_connection = false
    nsc_configs.each do |nsc_config|
      if nsc_config.is_active?
        @nsc_conn_manager.add_connection nsc_config
        added_connection = true
      end
    end

    if not nsc_configs or nsc_configs.empty?
      @logger.add_log_message "[!] There are no configured NSC connections"
    elsif not added_connection
      @logger.add_log_message "[!] There are no active NSC connections"
    end

    #Starts notification manager
    ScanStartNotificationManager.instance

    #Start scan manager
    ScanManager.instance

    # TODO: Need to develop a way to auto load modules
    TicketManager.instance
    @logger.add_log_message "[*] Loading ticket module"

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


