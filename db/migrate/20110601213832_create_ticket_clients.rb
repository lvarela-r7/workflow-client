class CreateTicketClients < ActiveRecord::Migration
  def self.up
    create_table :ticket_clients do |t|
      t.string :id
      t.string :client
      t.string :client_connector
      t.string :formatter
    end
  end

  def self.down
    drop_table :ticket_clients
  end
end
