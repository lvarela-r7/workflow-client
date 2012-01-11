class CreateModuleTypes < ActiveRecord::Migration
  def self.up
    create_table :module_types do |t|
      t.string :view
      t.string :title
      t.string :description
    end
  end

  def self.down
    drop_table :module_types
  end
end
