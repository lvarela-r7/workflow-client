class CreateScanHistoryTimeFrames < ActiveRecord::Migration
  def self.up
    create_table :scan_history_time_frames do |t|
      t.text :time_type
      t.integer :multiplicate
    end
  end

  def self.down
    drop_table :scan_history_time_frames
  end
end
