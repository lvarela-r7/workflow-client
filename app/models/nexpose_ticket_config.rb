class NexposeTicketConfig < ActiveRecord::Base

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
		model_params[:nexpose_default_user] = params[:nexpose_default_user]
		model_params[:nexpose_client_id] = params[:nexpose_client_id]
		model_params
	end
  
  def self.client_name
    'Nexpose'
  end

end
