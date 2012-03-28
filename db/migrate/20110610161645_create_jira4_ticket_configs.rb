class CreateJira4TicketConfigs < ActiveRecord::Migration
  def self.up
    create_table :jira4_ticket_configs do |t|
      t.text :assignee
      t.text :reporter
      t.text :project_name
      t.integer :issue_id
      t.integer :priority_id
      t.text :username
      t.text :password
      t.text :host
      t.integer :port
    end
  end

  def self.down
    drop_table :jira4_ticket_configs
  end
end
