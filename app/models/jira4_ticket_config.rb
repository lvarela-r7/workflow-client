class Jira4TicketConfig < ActiveRecord::Base
	validates_presence_of :username, :message => '(Jira 4 Ticket Client Config) The username cannot be empty'
	validates_presence_of :password, :message => '(Jira 4 Ticket Client Config) The password cannot be empty'
	validates_presence_of :host, :message => '(Jira 4 Ticket Client Config) The host cannot be empty'
	validates_presence_of :port, :message => '(Jira 4 Ticket Client Config) port cannot be empty'
	validates_presence_of :assignee, :message => '(Jira 4 Ticket Client Config) The Default assignee cannot be empty'
	validates_presence_of :project_name, :message => '(Jira 4 Ticket Client Config) The project name cannot be empty'
	validates_presence_of :issue_id, :message => '(Jira 4 Ticket Client Config) The issue ID cannot be empty'
	validates_presence_of :reporter, :message => '(Jira 4 Ticket Client Config) The default reporter cannot be empty'
	validates_presence_of :priority_id, :message => '(Jira 4 Ticket Client Config) The priority ID cannot be empty'

	has_one :ticket_config, :as => :ticket_client

	# TODO: Add validation for authentication data

	validate do |client|
		if client.ticket_config
			next if client.ticket_config.valid?
			client.ticket_config.errors.full_messages.each do |msg|
				errors.add_to_base msg
			end
		end
	end

	def self.parse_model_params params
		model_params = {}
		model_params[:assignee] 	= params[:assignee]
		model_params[:reporter] 	= params[:reporter]
		model_params[:project_name] = params[:project_name]
		model_params[:priority_id] 	= params[:priority_id]
		model_params[:issue_id] 	= params[:issue_id]
		model_params[:username] 	= params[:username]
		model_params[:password]		= params[:password]
		model_params[:host] 		= params[:host]
		model_params[:port] 		= params[:port]
		model_params
	end

	def self.client_name
		'Jira4x'
	end
end
