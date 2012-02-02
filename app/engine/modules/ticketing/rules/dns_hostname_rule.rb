require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class DNSHostnameRule < Rule
  def initialize hostname_list, is_whitelist=true
    @hostname_list = hostname_list
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data
    if @hostname_list.nil? or @hostname_list.empty?
      return false if @is_whitelist?
      return true
    end

    host = ticket_data[:host]

    if host.nil? or host.empty?
      raise "Host nil or empty in ticket data: #{ticket_data.inspect}"
    end

    @hostname_list.each do |h|
      next if host != h

      return true if @is_whitelist? #host was on white list, OK
      return false #host was on black list, BAD
    end

    return true if !@is_whitelist? #wasn't on blacklist
    return false #wasn't on white list, BAD
  end
end
