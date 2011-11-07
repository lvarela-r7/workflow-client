class RemedyTicketConfig < ActiveRecord::Base
	serialize :mappings, Hash

	has_one :ticket_config, :as => :ticket_client

	validate do |client|
		if client.ticket_config
			next if client.ticket_config.valid?
			client.ticket_config.errors.full_messages.each do |msg|
				errors.add_to_base msg
			end
		end
	end

	def self.parse_model_params params, wsdl_file_name, operation
		op_id = params[:remedy_ticket_op_id]
		key = "remedy_config_#{op_id}"
        input = params[key]

		# Add the operation and the file name
		input[:wsdl_file_name] = wsdl_file_name
		input[:operation] = operation
		input
	end
end
