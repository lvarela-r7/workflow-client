class CreateTicketRules < ActiveRecord::Migration
  def self.up
    create_table :ticket_rules do |t|
      t.boolean :use_vv
      t.boolean :use_ve
      t.boolean :use_vp
      t.integer :cvss_min
      t.integer :cvss_max
	  t.integer :ticket_config_id
    end
  end

  def self.down
    drop_table :ticket_rules
  end
end
