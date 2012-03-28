class CreateNscConfigs < ActiveRecord::Migration
  def self.up
    create_table :nsc_configs do |t|
      t.boolean :is_active
      t.text :username
      t.text :password
      t.text :silo_id
      t.text :host
      t.text :port
    end
  end

  def self.down
    drop_table :nsc_configs
  end
end