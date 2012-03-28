class CreateModuleTypes < ActiveRecord::Migration
  def self.up
    create_table :module_types do |t|
      t.text :view
      t.text :title
      t.text :description
    end
  end

  def self.down
    drop_table :module_types
  end
end
