class CreateTicketRules < ActiveRecord::Migration
  def self.up
    create_table :ticket_rules do |t|
      t.boolean :use_vv
      t.boolean :use_ve
      t.boolean :use_vp
      t.integer :cvss_min
      t.integer :cvss_max
      t.integer :pci_min
      t.integer :pci_max
      t.integer :ticket_config_id
      t.string  :ip_list
      t.boolean :ip_list_is_whitelist
      t.string  :dns_hostname_list
      t.boolean :dns_hostname_list_is_whitelist
      t.string  :dns_hostname_pcre_list
      t.boolean :dns_hostname_pcre_list_is_whitelist
      t.string  :site_list
      t.boolean :site_list_is_whitelist
      t.string  :site_pcre_list
      t.boolean :site_pcre_list_is_whitelist
    end
  end

  def self.down
    drop_table :ticket_rules
  end
end
