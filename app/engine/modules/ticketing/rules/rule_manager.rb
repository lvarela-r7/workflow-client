require File.expand_path(File.join(File.dirname(__FILE__), 'cvss_rule'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vuln_status_rule'))

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
    raise "Unable to find vuln data with id: #{vuln_id}" unless vuln_info

    vuln_hash = {}
    vuln_hash['vuln_id'] = vuln_info.vuln_id
    vuln_hash['vuln_data'] = vuln_info.vuln_data
    
    ticket.merge! vuln_hash

    @rules.each do |rule|
      unless rule.passes_rule? ticket['vuln_data']
        return false
      end
    end

    true
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
  end

end
