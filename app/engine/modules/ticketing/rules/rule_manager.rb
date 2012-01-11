require File.expand_path(File.join(File.dirname(__FILE__), 'cvss_rule'))
require File.expand_path(File.join(File.dirname(__FILE__), 'vuln_status_rule'))

class RuleManager

  def initialize rules
    build_rules rules
  end

  #
  # See TicketManager#build_ticket_data for all the attributes
  # on a ticket object.
  #
  def matches_rules? ticket
    vuln_info = TicketManager.instance.vuln_map[ticket[:vuln_id]]
    ticket.merge! vuln_info

    @rules.each do |rule|
      unless rule.passes_rule? ticket
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

    vuln_status_rule = VulnStatusRule.new rules.use_ve, rules.use_vv, rules.use_vp
    @rules << vuln_status_rule
  end

end