class CreateTicketingScopes < ActiveRecord::Migration
  def self.up
    create_table :ticketing_scopes do |t|
      t.string :name
      t.string :description
      t.integer :ticket_config_id
    end
  end

  def self.down
    drop_table :ticketing_scopes
  end
end
