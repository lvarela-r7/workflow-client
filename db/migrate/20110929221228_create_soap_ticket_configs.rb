class CreateSoapTicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :soap_ticket_configs do |t|
      t.text :mappings
    end
  end

  def self.down
    drop_table :soap_ticket_configs
  end
end
