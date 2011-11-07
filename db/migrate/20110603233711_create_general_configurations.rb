class CreateGeneralConfigurations < ActiveRecord::Migration
  def self.up
    create_table :general_configurations do |t|
      t.integer :scan_history_polling
      t.integer :scan_history_polling_time_frame
      t.integer :nsc_polling
    end
  end

  def self.down
    drop_table :general_configurations
  end
end
