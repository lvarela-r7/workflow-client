class ScanInfoRules < Ruleby::Rulebook

	def rules

		rule :scan_info, AND([ScanInfo, :s, m.status], [ScanInfo, :s, m.status.to_s.eql? "complete"]) do |v|
			  # Trigger the manager that retrieves scan completed information, then re-assert this
			  # scan info fact
		end
	end
end
