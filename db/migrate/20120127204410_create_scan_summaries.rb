class CreateScanSummaries < ActiveRecord::Migration
  def self.up
    create_table :scan_summaries do |t|
      t.text :host
      t.integer :site_id
      t.integer :scan_id
      t.datetime :start_time
      t.datetime :end_time
      t.text :status
    end
  end

  def self.down
    drop_table :scan_summaries
  end
end
