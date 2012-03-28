class CreateNexposeTicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :nexpose_ticket_configs do |t|
      t.text :nexpose_default_user
      t.integer :nexpose_client_id
    end
  end

  def self.down
    drop_table :nexpose_ticket_configs
  end
end
