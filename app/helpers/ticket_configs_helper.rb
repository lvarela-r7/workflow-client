module TicketConfigsHelper

	def is_sensitive_field? label
		case label
			when /password/i
				true
			else
				false
		end
	end

	def get_input_type input
		input_type = "("
		if input['type'].instance_of? Hash
			input_type += remove_namespace(input['type']['type'])
		else
			input_type += remove_namespace(input['type'])
		end

		input_type += ")"
		input_type
	end

	def is_required_input? input

		return !(input['minOccurs'].to_i == 0) if (input['minOccurs'])

		return (input['nillable'].to_s.eql?('false')) if (input['nillable'])

		true
	end

	def remove_namespace input
		if input.include? ':'
			return input.split(':')[1]
		end

		input
	end

	def get_headers headers, wsdl_operations
		map = {}
		headers.each do |header|
			map[header] = wsdl_operations[header]
		end

		map
	end

	def has_operations? input
		input.each do |key, value|
			unless 'headers'.eql? key
				return true
			end
		end

		false
	end
end
