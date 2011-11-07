class CreateLastScans < ActiveRecord::Migration
  def self.up
    create_table :last_scans do |t|
      t.string :host
      t.integer :scan_id
    end
  end

  def self.down
    drop_table :last_scans
  end
end
