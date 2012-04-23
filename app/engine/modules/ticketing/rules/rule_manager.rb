require File.expand_path(File.join(File.dirname(__FILE__), 'cvss_rule'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vuln_status_rule'))
require File.expand_path(File.join(File.dirname(__FILE__), 'ipv4_address_rule'))
require File.expand_path(File.join(File.dirname(__FILE__), 'dns_hostname_rule'))

class RuleManager

  def initialize(rules)
    build_rules rules
  end

  #
  # See TicketManager#build_ticket_data for all the attributes
  # on a ticket object.
  #
  def passes_rules?(ticket)
    vuln_id = ticket[:vuln_id]
    vuln_info = VulnInfo.find_by_vuln_id(vuln_id)
    if vuln_info
      vuln_hash = {}
      vuln_hash['vuln_id'] = vuln_info.vuln_id
      vuln_hash['vuln_data'] = vuln_info.vuln_data
      vuln_hash['vuln_data'][:ip] = ticket[:ip]
      vuln_hash['vuln_data'][:host] = ticket[:name]

      ticket.merge! vuln_hash

      @rules.each do |rule|
        unless rule.passes_rule? ticket['vuln_data']
          return false
        end
      end
    else #ticket per device?
      device_data = {}
      device_data[:ip] = ticket[:ip]
      device_data[:name] = ticket[:name]

      @rules.each do |rule|
        unless rule.passes_rule? device_data
          return false
        end
      end
    end

    return true
  end

  #
  #
  #
  def build_rules rules
    @rules = []

    cvss_rule = CVSSRule.new rules.cvss_min, rules.cvss_max
    @rules << cvss_rule

    pci_rule = PCIRule.new rules.pci_min, rules.pci_max
    @rules << pci_rule

    vuln_status_rule = VulnStatusRule.new rules.use_ve, rules.use_vv, rules.use_vp
    @rules << vuln_status_rule

    if rules.ip_list and !rules.ip_list.empty?
      ipv4_rule = IPv4ListRule.new rules.ip_list, rules.ip_list_is_whitelist
      @rules << ipv4_rule
    end

    if rules.dns_hostname_list and !rules.dns_hostname_list.empty?
      dns_hostname_rule = DNSHostnameRule.new rules.dns_hostname_list, rules.dns_hostname_list_is_whitelist
      @rules << dns_hostname_rule
    end
  end

end
