class CreateTicketsToBeCreateds < ActiveRecord::Migration
  def self.up
    create_table :tickets_to_be_createds do |t|
      t.string :ticket_id
      t.text :ticket_data
    end
  end

  def self.down
    drop_table :tickets_to_be_createds
  end
end
