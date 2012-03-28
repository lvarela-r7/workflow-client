class CreateJira3TicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :jira3_ticket_configs do |t|
      t.integer :project_id
      t.integer :priority_id
      t.integer :assignee_id
      t.text :default_reporter
      t.integer :issue_type_id
      t.text :username
      t.text :password
      t.text :host
      t.integer :port
    end
  end

  def self.down
    drop_table :jira3_ticket_configs
  end
end
