class CreateJira4TicketConfigs < ActiveRecord::Migration
  def self.up
	  create_table 	:jira4_ticket_configs do |t|
		  t.string 	:assignee
		  t.string 	:reporter
		  t.string 	:project_name
		  t.integer	:issue_id
		  t.integer :priority_id
		  t.string 	:username
		  t.string 	:password
		  t.string 	:host
		  t.integer :port
	  end
  end

  def self.down
    drop_table :jira4_ticket_configs
  end
end
