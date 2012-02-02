require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class DNSHostnameRegexRule < Rule
  def initialize hostname_regex_list, is_whitelist=true
    @hostname_regex_list = hostname_regex_list
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data
    if @hostname_regex_list.nil? or @hostname_regex_list.empty?
      return false if @is_whitelist? #can't pass whitelist rule if nothing on whitelist
      return true #always passes rule if blacklist empty
    end

    host = ticket_data[:host]

    if host.nil? or host.empty?
      raise "Host nil or empty in ticket data: #{ticket_data.inspect}"
    end

    @hostname_regex_list.each do |regex|
      next if host !~ /#{regex}/

      return true if @is_whitelist
      return false
    end

    return false if @is_whitelist
    return true
  end
end
