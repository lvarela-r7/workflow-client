class TicketingRules < Ruleby::Rulebook

  def rules
    rule :ticketing_rules, [ScanInfo, :s, m.has_scan_data?] do |v|
      # Retrieve the scan data and do ticketing.
    end
  end
end