class LastSiteScan
	def initialize
		@last_site_scan_id = {}
	end

	def add_last_site_scan site_id, scan_id

		old_scan_id = @last_site_scan_id[site_id]
		unless old_scan_id.nil?
			if scan_id.to_i > old_scan_id.to_i
				@last_site_scan_id[site_id] = scan_id
			end
		else
			@last_site_scan_id[site_id] = scan_id
		end
	end

	def get_last_scan_id site_id
		@last_site_scan_id[site_id] || -1
	end
end