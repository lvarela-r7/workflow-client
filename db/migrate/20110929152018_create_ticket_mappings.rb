class CreateTicketMappings < ActiveRecord::Migration
  def self.up
    create_table :ticket_mappings do |t|
      t.text :node_address
      t.text :node_name
      t.text :vendor
      t.text :product
      t.text :family
      t.text :version
      t.text :vulnerability_status
      t.text :vulnerability_id
      t.text :description
      t.text :proof
      t.text :solution
      t.text :scan_start
      t.text :scan_end
      t.text :cvss_score
      t.integer :ticket_config_id
    end
  end

  def self.down
    drop_table :ticket_mappings
  end
end
