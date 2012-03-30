class CreateTicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :ticket_configs do |t|
      t.boolean :is_active
      t.boolean :supports_updates, :default => false
      t.integer :scope_id
      t.text :module_name
      t.references :ticket_client, :polymorphic => true
    end
  end

  def self.down
    drop_table :ticket_configs
  end
end
