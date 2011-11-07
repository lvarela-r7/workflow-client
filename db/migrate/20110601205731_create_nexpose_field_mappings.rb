class CreateNexposeFieldMappings < ActiveRecord::Migration
  def self.up
    create_table :nexpose_field_mappings do |t|
      t.string :node_address
      t.string :node_name
      t.string :vendor
      t.string :product
      t.string :family
      t.string :version
      t.string :vulnerability_status
      t.string :vulnerability_id
      t.string :description
      t.string :proof
      t.string :solution
      t.string :scan_start
      t.string :scan_end
    end
  end

  def self.down
    drop_table :nexpose_field_mappings
  end
end
