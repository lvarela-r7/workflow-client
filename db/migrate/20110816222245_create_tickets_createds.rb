class CreateTicketsCreateds < ActiveRecord::Migration
  def self.up
    create_table :tickets_createds do |t|
      t.string :host
      t.string :module_name
      t.string :ticket_id
    end
  end

  def self.down
    drop_table :tickets_createds
  end
end
