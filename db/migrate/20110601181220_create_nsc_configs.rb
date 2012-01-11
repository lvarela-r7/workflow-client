class CreateNscConfigs < ActiveRecord::Migration
  def self.up
    create_table :nsc_configs do |t|
      t.boolean :is_active
      t.string :username
      t.string :password
      t.string :silo_id
      t.string :host
      t.string :port
    end
  end

  def self.down
    drop_table :nsc_configs
  end
end