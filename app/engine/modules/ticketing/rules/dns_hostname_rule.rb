require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class DNSHostnameRule < Rule
  def initialize hostname_list, is_whitelist=true
    @hostname_list = hostname_list
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data
    if @hostname_list.nil? or @hostname_list.empty?
      if @is_whitelist == true
        return false
      end

      return true
    end

    host = ticket_data[:host]

    if host.nil? or host.empty?
      raise "Host nil or empty in ticket data: #{ticket_data.inspect}"
    end

    @hostname_list.split("\n").each do |h|
      next if h.empty?
      next if host != h

      if @is_whitelist == true
        return true
      end

      return false
    end

    if @is_whitelist == false
      return true  #wasn't on blacklist
    end
    return false #wasn't on white list, BAD
  end
end
