class CreateIntegerProperties < ActiveRecord::Migration
  def self.up
    create_table :integer_properties do |t|
      t.text :property_key
      t.integer :property_value
    end
  end

  def self.down
    drop_table :integer_properties
  end
end
