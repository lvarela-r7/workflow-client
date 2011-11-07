class CreateTicketMappings < ActiveRecord::Migration
	def self.up
		create_table :ticket_mappings do |t|
			t.string :node_address
			t.string :node_name
			t.string :vendor
			t.string :product
			t.string :family
			t.string :version
			t.string :vulnerability_status
			t.string :vulnerability_id
			t.string :description
			t.string :proof
			t.string :solution
			t.string :scan_start
			t.string :scan_end
			t.string :cvss_score
			t.integer :ticket_config_id
		end
	end

	def self.down
		drop_table :ticket_mappings
	end
end
