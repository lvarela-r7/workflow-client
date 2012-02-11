require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class SiteListRegexRule < Rule
  def initialize site_list_regex_csv, is_whitelist=true
    @site_list_regex_csv = site_list_regex_csv
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data
    if @site_list_regex_csv.nil? or @site_list_regex_csv.empty?
      return false if @is_whitelist?
      return true
    end

    site_name = ticket_data[:site]

    if site_name.nil? or site_name.empty?
      raise "No sitename passed in ticket data: #{ticket_data.inspect}"
    end

    site_regex_list = @site_regex_list_csv.split ","

    site_regex_list.each do |site_regex|
      if site_name =~ /#{site_regex}/
        return true if @is_whitelist?
        next
      end
    end

    return false if @is_whitelist?
    return true
  end
end
