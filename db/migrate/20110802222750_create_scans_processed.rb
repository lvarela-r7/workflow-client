class CreateScansProcessed < ActiveRecord::Migration
  def self.up
    create_table :scans_processed do |t|
      t.text :host
      t.text :scan_id
      t.text :module
    end
  end

  def self.down
    drop_table :scans_processed
  end
end
