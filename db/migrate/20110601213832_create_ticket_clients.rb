class CreateTicketClients < ActiveRecord::Migration
  def self.up
    create_table :ticket_clients do |t|
      t.text :id
      t.text :client
      t.text :client_connector
      t.text :formatter
    end
  end

  def self.down
    drop_table :ticket_clients
  end
end
