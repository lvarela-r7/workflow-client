require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))
require 'ipaddr'

class IPv4ListRule < Rule

  def initialize ip_list_csv, is_whitelist=true
    @ip_list_csv = ip_list_csv
    @is_whitelist = is_whitelist
  end

  def passes_rule? ticket_data

    #no need to test if no rules exist
    if @ip_list_csv.nil? or @ip_list_csv.empty?
      return
    end

    ip = IPAddr.new(ticket_data[:ip])

    #split ip rule list
    ip_list = @ip_list_csv.split ","
    
    return_val = !@is_whitelist

    ip_list.each do |ip_rule|

      #if is_whitelist, return whether the ip is contained in the range
      #if !is_whitelist, return whether the ip is *not* in the range
      if ip_rule =~ /\//
        return return_val if !(ip === IPAddr.new(ip_rule))

      #if is_whitelist, return whether the ip is between the two ip addresses
      #if !is_whitelist, return whether ip is *not* between the two ip addresses
      elsif ip_rule=~ /-/
        range = ip_rule.split "-"
        return return_val if !((IPAddr.new(range[0]).to_i..IPAddr.new(range[1]).to_i)===ip.to_i)

      #if is_whitelist, return whether the ip address == the ip rule
      #if !is_whitelist, return whether the ip address != the ip rule
      else
        return return_val if IPAddr.new(ip_rule) == ip
      end

    end

    return !return_val
  end
end
