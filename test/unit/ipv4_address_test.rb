require_relative '../app/engine/modules/ticketing/rules/ipv4_address_rule'
require 'test_helper'

class IPv4RuleTest < ActiveSupport::TestCase

  #some random ip's and ranges
  ip_list = "192.168.1.0/24,192.168.0.0-192.168.0.255,192.168.1.123"

  ips = []

  ips << "192.168.1.123"
  ips << "192.168.0.123"
  ips << "127.0.0.1"

  ips.each do |ip|

    p "Testing #{ip}"
    ticket_data = {}
    ticket_data[:ip] = ip

    p "IP #{ip} is contained in #{ip_list}? (implicit whitelist)"
    rule = IPv4ListRule.new(ip_list)
    p rule.passes_rule? ticket_data

    p "IP #{ip} is contained in #{ip_list}? (explicit whitelist)"
    rule = IPv4ListRule.new(ip_list, true)
    p rule.passes_rule? ticket_data

    p "IP #{ip} is *not* contained in #{ip_list}? (explicit blacklist)"
    rule = IPv4ListRule.new(ip_list, false)
    p rule.passes_rule? ticket_data
  end
end
