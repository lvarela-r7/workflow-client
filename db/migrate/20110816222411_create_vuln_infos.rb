class CreateVulnInfos < ActiveRecord::Migration
  def self.up
    create_table :vuln_infos do |t|
      t.text :vuln_id
      t.text :vuln_data
    end
  end

  def self.down
    drop_table :vuln_infos
  end
end
