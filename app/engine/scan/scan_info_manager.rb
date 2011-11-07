require File.expand_path(File.join(File.dirname(__FILE__), 'scan_info'))

class ScanInfoManager

	def initialize
		@scan_info_objects = {}
	end

	def get_scan_info scan_id
		@scan_info_objects[scan_id]
	end

	def add_scan_info scan_id
		# Don't add if already exists
		unless @scan_info_objects.has_key? scan_id
			scan_info = ScanInfo.new scan_id
			@scan_info_objects[scan_id] = scan_info
		end
	end
end