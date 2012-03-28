class CreateTicketsCreateds < ActiveRecord::Migration
  def self.up
    create_table :tickets_createds do |t|
      t.text :ticket_id, :null => false
      t.text :update_id
      t.text :remote_key
    end
  end

  def self.down
    drop_table :tickets_createds
  end
end
