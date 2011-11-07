class CreateScansProcessed < ActiveRecord::Migration
  def self.up
    create_table :scans_processed do |t|
      t.string :host
      t.string :scan_id
	  t.string :module
    end
  end

  def self.down
    drop_table :scans_processed
  end
end
