require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class SiteListRule < Rule
  def initialize site_list_csv, is_whitelist=true
    @site_list_csv = site_list_csv
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data

    if @site_list_csv.nil? or @site_list_csv.empty?
      return false if @is_whitelist?
      return true
    end

    site_name = ticket_data[:site]

    if site_name.nil? or site_name.empty?
      raise "No sitename passed in ticket data: #{ticket_data.inspect}"
    end

    site_list = @site_list_csv.split ","

    site_list.each do |site|
      if site == site_name
        return true if @is_whitelist?
        next
      end
    end

    return false if @is_whitelist?
    return true
  end
end
