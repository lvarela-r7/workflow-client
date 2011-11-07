class WSDLUtil


	def initialize parsed_wsdl
		@parsed_wsdl = parsed_wsdl
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Returns a map of operations to needed input for executing that operation. The input needed is a map
	# broken up by :body and :headers which both contain an array of element mappings of the basic inputs needed.
	# The basic input is a map of :name, :type, and possible a :minOccurs value.
	#
	# ie: Get => [:body =>[{"Get" => [[{:name => "ID", :type => "xsd:string"}]]}]]}, :header => nil]
	#
	# @exclude_file_ops - Remove all types that indicate file upload ie: xsd:base64Binary
	#-------------------------------------------------------------------------------------------------------------------
	def get_operations_and_parameters exclude_file_ops
		ops_and_params = {}

		operations_and_headers.each do |message_type, enclosed_body|
			enclosed_body.each do |key, value|
				outer_map = {}

				# Load the messages
				value.flatten.each do |message|
					inner_map = {}
					unless "message".eql? message
						# Strip off the namespace
						message = strip_namespace message

						# Look up the parts for this message in the messages struct
						parts = @parsed_wsdl.messages[message].flatten
						parts.each do |part|
							unless part =~ /part/
								stripped_part = strip_namespace(part)
								translated_element = @parsed_wsdl.elements[stripped_part] || stripped_part
								if translated_element
									input_data = load_types_for_part strip_namespace(translated_element)
									if input_data
										if exclude_file_ops
											remove_file_ops input_data
										end
										unless inner_map[stripped_part]
											inner_map[stripped_part] = []
										end
										inner_map[stripped_part] = input_data
									end
								end
							end
						end
					end
					unless inner_map.empty?
						if outer_map[message_type]
							outer_map[message_type].merge! inner_map
						else
							outer_map[message_type] = inner_map
						end
					end
				end
				if ops_and_params[key]
				   ops_and_params[key].merge! outer_map
				else
					ops_and_params[key] = outer_map
				end

			end
		end

		ops_and_params
	end

	###################
	# PRIVATE METHODS #
	###################
	private

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def operations_and_headers
		merged = {}
		merged[:body] = @parsed_wsdl.operations
		merged[:header] = @parsed_wsdl.headers
		merged
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def strip_namespace name
		if name.include? ":"
			name = name.split(":")[1]
		end

		name
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Remove all related file input entries
	#-------------------------------------------------------------------------------------------------------------------
	def remove_file_ops input_array

		names_to_remove = []

		input_array.each_index do |index|
			data = input_array[index]

			# The last index indicates type
			if data[:type] =~ /base64/
				names_to_remove << data[:name]
            end
		end

		data_types_to_delete = []
		names_to_remove.each do |name|
			# TODO: Explain!
			if name.include? '_'
				name = name.split("_")[0].to_s
			end

			input_array.each do |data|
				if data[:name].include? name
					data_types_to_delete << data
				end
			end
		end

		data_types_to_delete.each do |data_type_to_delete|
			input_array.delete data_type_to_delete
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#
	#-------------------------------------------------------------------------------------------------------------------
	def load_types_for_part part
		parsed_types = @parsed_wsdl.types[part]
	    output_data = []

		if parsed_types
			parsed_types.each do |type|
				# These are all arrays
				added_data = {}
				skip_next = false

				type.each_index do |index|

					if skip_next
						skip_next = false
						next
					end

					type_info = type[index].to_s
					next_type_info = type[index + 1].to_s

					case type_info
						when 'name', 'value', 'minOccurs'
							added_data[type_info.to_s.intern] = next_type_info
							skip_next = true

						when 'type'
							added_data[type_info.to_s.intern] = next_type_info
							unless next_type_info.to_s.start_with? 'xsd'
								# In this case, we have a defined data type
								added_data[type_info.to_s.intern] = load_types_for_part(strip_namespace(next_type_info))
							else
								added_data[type_info.to_s.intern] = next_type_info
							end
							skip_next = true
					end
				end

				unless added_data.empty?
					output_data << added_data
				end
			end
		end

		output_data
	end

end