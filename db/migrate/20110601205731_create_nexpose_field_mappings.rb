class CreateNexposeFieldMappings < ActiveRecord::Migration
  def self.up
    create_table :nexpose_field_mappings do |t|
      t.text :node_address
      t.text :node_name
      t.text :vendor
      t.text :product
      t.text :family
      t.text :version
      t.text :vulnerability_status
      t.text :vulnerability_id
      t.text :description
      t.text :proof
      t.text :solution
      t.text :scan_start
      t.text :scan_end
    end
  end

  def self.down
    drop_table :nexpose_field_mappings
  end
end
