class Jira3TicketConfig < ActiveRecord::Base

	validates_presence_of :username, :message => '(Jira 3 Ticket Client Config) The username cannot be empty'
	validates_presence_of :password, :message => '(Jira 3 Ticket Client Config) The password cannot be empty'
	validates_presence_of :host, :message => '(Jira 3 Ticket Client Config) The host cannot be empty'
	validates_presence_of :port, :message => '(Jira 3 Ticket Client Config) port cannot be empty'
	validates_presence_of :project_id, :message => '(Jira 3 Ticket Client Config) The Project ID cannot be empty'
	has_one :ticket_config, :as => :ticket_client

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
		model_params[:project_id] 		= params[:project_id]
		model_params[:priority_id]	 	= params[:priority_id]
		model_params[:assignee_id] 		= params[:assignee_id]
		model_params[:default_reporter] = params[:default_reporter]
		model_params[:issue_type_id] 	= params[:issue_type_id]
		model_params[:username] 		= params[:username]
		model_params[:password] 		= params[:password]
		model_params[:host]	 			= params[:host]
		model_params[:port] 			= params[:port]
		model_params
	end

	def self.client_name
		'Jira3x'
	end

end
