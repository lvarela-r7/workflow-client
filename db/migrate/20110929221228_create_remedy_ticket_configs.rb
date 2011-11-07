class CreateRemedyTicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :remedy_ticket_configs do |t|
      t.text :mappings
    end
  end

  def self.down
    drop_table :remedy_ticket_configs
  end
end
