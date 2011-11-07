module TicketConfigsHelper


	def normalize_array_map_to_string_array wsdl_val_array
		values = []
		wsdl_val_array.each do |input|
			values << input[:value]
		end

		values
	end

	def is_sensitive_field? label
		case label
			when /password/i
				true
			else
				false
		end
	end

	def convert_array_to_value_map input
		map = {}

		input.each_index do |index|
			map[input[index]] = index
		end

		map
	end

end
