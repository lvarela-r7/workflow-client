class CreateTicketsToBeProcessed < ActiveRecord::Migration
  def self.up
    create_table :tickets_to_be_processeds do |t|
      t.string  :ticket_id
      t.text    :ticket_data
      t.boolean :pending_requeue, :default => false
      t.integer :failed_attempt_count, default => 0
      t.string  :failed_message
    end
  end

  def self.down
    drop_table :tickets_to_be_processeds
  end
end
