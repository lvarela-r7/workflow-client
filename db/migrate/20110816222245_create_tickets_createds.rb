class CreateTicketsCreateds < ActiveRecord::Migration
  def self.up
    create_table :tickets_createds do |t|
      t.string :ticket_id, :null => false
      t.string :update_id
      t.string :remote_key
    end
  end

  def self.down
    drop_table :tickets_createds
  end
end
