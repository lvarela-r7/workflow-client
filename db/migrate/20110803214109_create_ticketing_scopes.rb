class CreateTicketScopes < ActiveRecord::Migration
  def self.up
    create_table :ticket_scopes do |t|
      t.string :name
      t.string :description
      t.integer :ticket_config_id
    end
  end

  def self.down
    drop_table :ticket_scopes
  end
end
