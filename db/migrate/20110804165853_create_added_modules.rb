class CreateAddedModules < ActiveRecord::Migration
  def self.up
    create_table :added_modules do |t|
      t.text :module_name
      t.text :module_type
      t.text :edit_path
      t.text :delete_path
      t.boolean :is_active
    end
  end

  def self.down
    drop_table :added_modules
  end
end
