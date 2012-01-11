class CreateJira3TicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :jira3_ticket_configs do |t|
      t.integer :project_id
      t.integer :priority_id
      t.integer :assignee_id
      t.string :default_reporter
      t.integer :issue_type_id
      t.string :username
      t.string :password
      t.string :host
      t.integer :port
    end
  end

  def self.down
    drop_table :jira3_ticket_configs
  end
end
