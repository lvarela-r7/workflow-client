require 'rubygems'
require 'nexpose'
require 'observer'
require File.expand_path(File.join(File.dirname(__FILE__), '../logging/log_manager'))
require File.expand_path(File.join(File.dirname(__FILE__), '../net/nsc_conn_manager'))


#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# This class is used to find the latest scans per site that falls within the user configured
# time period.  These scans are then passed into the main ticketing system.
#
# == ALORITHM DEFINITION:
# Scans in nexpose are incremental, starting from 1 to current scan ID.
# In a constantly running thread:
# 1. Start from scan_id = 1
# 2. For the host, scan ID, and module-key we check to see if this exists in the scans_processed table
# 3. Next we call scan_statistics(scan_id) to determine if the date matches the range
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

# TODO: Add to the DB Manager scan-id's processed, and associated site-ids
# TODO: Ensure site is not currently being scanned before generating the report
# TODO: Possibly check site devices as well - phase 2
class ScanHistoryManager
  include Observable

  private_class_method :new

  def self.instance
    @@instance = new unless @@instance
    @@instance
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    # A map of
    @site_last_scanned = {}
    @nsc_conn_manager = NSCConnectionManager.instance
    general_config = GeneralConfiguration.find 1
    time_frame_id = general_config.scan_history_polling_time_frame
    @time_range = Time.now - (ScanHistoryTimeFrame.find_by_id time_frame_id).multiplicate
  end

  #---------------------------------------------------------------------------------------------------------------------
  #
  #---------------------------------------------------------------------------------------------------------------------
  def do_scan_history_check


    # Load all the sites
    sites = @client_api.site_listing

    # Get the scan history for each
    sites.each do |site|
      site_id = site[:site_id]
      site_scan_history = @client_api.site_scan_history site[site_id]
      set_last_site_scan site_scan_history, site_id
    end

  end

  #------------------------------------------------------------------------------------------------------
  # Parses scan history to determine if there
  #------------------------------------------------------------------------------------------------------
  def set_last_site_scan site_scan_history, site_id
    last_scan_id = @db_manager.get_last_scan_id site_id
    last_site_scan_object = nil

    # Loop over site scan history
    site_scan_history.each do |site_scan_info|
      current_scan_id = site_scan_info[:scan_id]
      if current_scan_id < last_scan_id or site_scan_info[:end_time].nil?
        next
      end

      # TODO: Check to ensure the date is within the time frame desired
      utc_end_time = parse_utc_time site_scan_info[:end_time]
      if not utc_end_time or (utc_end_time <=> @time_range) == -1
        next
      end

      if last_site_scan_object.nil? or site_scan_info[:scan_id].to_i > last_site_scan_object[:scan_id].to_i
        last_site_scan_object = site_scan_info
        next
      end
    end

    # Here is where we insert these facts into the RETE
    unless last_site_scan_object.nil?
      scan_id = last_site_scan_object[:scan_id]
      @ticket_manager.handle_ticket scan_id
      @db_manager.add_last_site_scan site_id, scan_id
    end
  end




end