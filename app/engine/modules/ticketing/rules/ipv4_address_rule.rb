require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))
require 'ipaddr'

class IPv4ListRule < Rule

  def initialize ip_list_csv, is_whitelist=true
    @ip_list_csv = ip_list_csv
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data
    if @ip_list_csv.nil? or @ip_list_csv.empty?
      return
    end

    ip = IPAddr.new(ticket_data[:ip])
    ip_list = @ip_list_csv.split ","
    return_val = !@is_whitelist

    ip_list.each do |ip_rule|
      if ip_rule =~ /\//
        return return_val if !(ip === IPAddr.new(ip_rule))
      elsif ip_rule=~ /-/
        range = ip_rule.split "-"
        return return_val if !((IPAddr.new(range[0]).to_i..IPAddr.new(range[1]).to_i)===ip.to_i)
      else
        return return_val if IPAddr.new(ip_rule) == ip
      end

    end

    return !return_val
  end
end
