class WSDLUtil


	def initialize parsed_wsdl
		@parsed_wsdl = parsed_wsdl
	end

	# operations_name => [port]
	#

	#-------------------------------------------------------------------------------------------------------------------
	#
	# PortType => {operation => {body => [{type definitions}], header => {header definitions} }}
	#
	# 1. For each port type iterate over the port_type array and find where the 'name' is equal
	# 2. Aggregate an array of messages where element_name is of type /input/ (we want to store the name of the message)
	# 3. From the array in 2 convert each message into its individual parts if there is a type we store that array
	#    if NOT we search for the complex type parts from the types map.
	#
	# @exclude_file_ops - Remove all types that indicate file upload ie: xsd:base64Binary
	#-------------------------------------------------------------------------------------------------------------------
	def get_soap_input_operations exclude_file_ops
		ops_and_params = {}

		operations_and_headers.each do |port_type, operations|
			ops_and_params[port_type] = {}

			operations.each do |operation|
				# First handle headers
				headers = operation['headers']
				unless headers.nil? && headers.empty?
					headers.each do |header|
						if ops_and_params[port_type]['headers'].nil?
							ops_and_params[port_type]['headers'] = {}
						end

						header = remove_namespace(header)
						header_elements = get_message_parts(header)
						ops_and_params[port_type]['headers'][header] = header_elements
					end
				end

				# We first need to retrieve the message inputs from the port_types
				# We then retrieve the types for the message
				if ops_and_params[port_type]['operations'].nil?
					ops_and_params[port_type]['operations'] = {}
				end
				op_name = remove_namespace(operation['operation_name'].to_s)
				ops_and_params[port_type]['operations'][op_name] = load_types_from_port_type_op op_name

				# Load the headers needed
				ops_and_params[port_type]['operations'][op_name]['headers'] = operation['headers']
			end
		end

		ops_and_params
	end

	###################
	# PRIVATE METHODS #
	###################
	private

	def load_types_from_port_type_op operation

		type_map = {}

		node = load_port_type_with_name operation
		node.each do |child|
			if child['element_name'] =~ /input/
				type_map.merge! get_message_parts child['message']
			end
		end

		type_map
	end

	def load_port_type_with_name operation
		port_types = @parsed_wsdl.port_types
		port_types.each do |port_type|
			name = port_type['name']
			if operation.eql? name
			   return port_type['children']
			end

			port_type_children = port_type['children']
			if (!port_type_children.nil? and !port_type_children.empty?)
				port_types.concat port_type['children']
			end
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	# returns an array of the basic message data types
	# TODO: for now only returns input types
	#-------------------------------------------------------------------------------------------------------------------
	def get_message_parts message_name
		core_data_map = {}

		# Find the message
		@parsed_wsdl.messages.each do |message|
			# We found the message, now load all the input
			if message_name =~ /#{message['name']}/
				# Parse over children where 'name' == parameters
				# look for base data type in the types array
				# TODO: See if there is a better way to do this

				message_children = message['children']
				parent_name = remove_namespace(message_name)
				unless (message_children.nil? and message_children.empty?)
					message_children.each do |message_child|
						if message_child['name'] =~ /parameters/i
							# Load data array from types map
							type_name = remove_namespace(message_child['element'])
							loaded_types = load_from_type_map type_name

							unless (loaded_types.nil? and loaded_types.empty?)
								core_data_map.update loaded_types
							end
						else
							if core_data_map[parent_name].nil?
								core_data_map[parent_name] = []
							end

							core_data_map[parent_name] << message_child
						end
					end
				end

			end
		end

		core_data_map
	end

	def remove_namespace name
		if name.include? ':'
			name = name.split(':')[1]
		end
		name
	end
	#-------------------------------------------------------------------------------------------------------------------
	# Loads all the base elements from the type map
	#-------------------------------------------------------------------------------------------------------------------
	def load_from_type_map name_sought
		# Parse tree until 'name' = type_name
		# then parse children and get all element_name = element, has a 'name' and 'type'

		data_types = {}
		children = []
		top_level_elements = @parsed_wsdl.types

		# Start parse over the 'types' elements
		top_level_elements.each do |type_element|
			type_element_children = type_element['children']
			type_name = type_element['name']

			# If the base elements are sub-elements
			if (!type_element_children.nil? && !type_element_children.empty? && type_name =~ /#{ name_sought}/)
				# We found what we are looking for now parse over the children
				parent_name = type_element['name']
				children.concat type_element_children
				children.each do |child|
					# Is this a child we want
					child_element_name = child['element_name']
					if (!child_element_name.nil? && child_element_name =~ /element/ && !child['name'].nil? && !child['type'].nil?)
						if data_types[parent_name].nil?
							data_types[parent_name] = []
						end
						data_types[parent_name] << child
					else
						# Don't modify the base data structure
						child_children = child['children'].clone
						child_name = child['name']
						if (!child_name.nil? && !child_name.empty?)
							parent_name = child_name
						end

						if child_children.nil? or child_children.empty?
							next
						end

						# Add the children to be parsed over
						children.concat child_children
					end

				end
				# We found the node we were looking for now break out
				break

		    # If the element is referenced by another
			elsif type_element['name'] =~ /#{ name_sought}/
				type_of_element = remove_namespace(type_element['type'])
				if !type_of_element.nil?
					# Detect loop
					unless type_of_element.to_s.eql? type_name
						# Then recurse
						return load_from_type_map (remove_namespace(type_of_element))
					end
				end
			end

			# Keep adding the child elements
			child_elements = type_element['children']
			if (!child_elements.nil? && !child_elements.empty?)
				top_level_elements.concat child_elements
			end
		end

		data_types
	end

	#-------------------------------------------------------------------------------------------------------------------
	# The goal here is to create an array of bindings with addition input and the the operation data.
	# This function returns a hash of port_type to an array of the operations and headers needed.
	# Ex: port_type => [operation_name => OP, headers => [message+headers]]
	#-------------------------------------------------------------------------------------------------------------------
	def operations_and_headers
		output = {}

		# iterate over bindings
		@parsed_wsdl.bindings.each do |binding|
			#find the operation name and additional input
			port_type = remove_namespace(binding['type'].to_s)

			child_bindings = binding['children']
			is_soap_binding = false
			child_bindings.each do |child_binding|

				if child_binding['element_name'] =~ /soap/ and not is_soap_binding
					is_soap_binding = true
				end

				if child_binding['element_name'] =~ /operation/
					input = {}
					operation_name = child_binding['name']
					input['operation_name'] = operation_name
					if exists?(port_type, operation_name, output)
						next
					end

					# For now we just care to parse out all the input headers if any.
					next_nodes = child_binding['children']
					input['headers'] = []
					next_nodes.each do |next_node|
						if next_node['element_name'] =~ /input/
							# See if the input contains headers
							child_nodes = next_node['children']
							unless child_nodes.nil?
								child_nodes.each do |child_node|
									if child_node['element_name'] =~ /header/
										input['headers'] << remove_namespace(child_node['message'])
									end
								end
							end
						end
					end

					if is_soap_binding
						if output[port_type].nil?
							output[port_type] = []
						end
						output[port_type] << input
					end
				end
			end
		end
		output
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def exists? port_type, opertaion_name, output_hash
		data_array = output_hash[port_type]
		if data_array.nil?
			return false
		end

		data_array.each do |data|
			if data['operation_name'].to_s.eql?(opertaion_name)
				return true
			end
		end

		false
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