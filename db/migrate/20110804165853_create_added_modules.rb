class CreateAddedModules < ActiveRecord::Migration
  def self.up
    create_table :added_modules do |t|
      t.string :module_name
      t.string :module_type
      t.string :edit_path
      t.string :delete_path
	  t.boolean :is_active
    end
  end

  def self.down
    drop_table :added_modules
  end
end
