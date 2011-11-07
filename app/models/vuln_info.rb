class VulnInfo < ActiveRecord::Base
	serialize :vuln_data, Hash
end
