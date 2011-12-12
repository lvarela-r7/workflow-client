#-----------------------------------------------------------------------------------------------------------------------
# Class used to perform operations on a parsed WSDL file.
#
# @author: Christopher Lee, christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

class WSDLUtil

	# TODO: Array parsing and representation

	FILE_TYPES = ['base64Binary']

	#-------------------------------------------------------------------------------------------------------------------
	# This utility uses an underlying parsed WSDL object to perform operations.
	#-------------------------------------------------------------------------------------------------------------------
	def initialize parsed_wsdl
		@parsed_wsdl = parsed_wsdl
		@exclude_file_ops = false
	end

	#-------------------------------------------------------------------------------------------------------------------
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

		if @parsed_wsdl.wsdl_version != 1.2
		 	raise "Unsupported WSDL version: #{@parsed_wsdl.wsdl_version}"
		end

		@exclude_file_ops = exclude_file_ops
		ops_and_params = {}

		operations_and_headers.each do |port_type, operations|
			ops_and_params[port_type] = {}

			operations.each do |operation|
				# First handle headers
				headers = operation['headers']
				if ops_and_params[port_type]['headers'].nil?
					ops_and_params[port_type]['headers'] = {}
				end
				if (!headers.nil? && !headers.empty?)
					headers.each do |header|

						header = remove_namespace(header)
						header_elements = get_message_parts(header)
						ops_and_params[port_type]['headers'][header] = header_elements
					end
				else
					# Load basic auth headers
					ops_and_params[port_type]['headers']['Basic Authentication'] = load_basic_auth
				end

				# We first need to retrieve the message inputs from the port_types
				# We then retrieve the types for the message
				if ops_and_params[port_type]['operations'].nil?
					ops_and_params[port_type]['operations'] = {}
				end
				op_name = remove_namespace(operation['operation_name'].to_s)
				ops_and_params[port_type]['operations'][op_name] = load_types_from_port_type_op op_name

				# Load the headers needed
				headers_for_op = operation['headers']
				if (headers_for_op.nil? || headers_for_op.empty?)
					headers_for_op = ['Basic Authentication']
				end
				ops_and_params[port_type]['operations'][op_name]['headers'] = headers_for_op
			end
		end

		ops_and_params
	end

	###################
	# PRIVATE METHODS #
	###################
	private

	#-------------------------------------------------------------------------------------------------------------------
	# Finds all the base types from a portType
	#-------------------------------------------------------------------------------------------------------------------
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

	#-------------------------------------------------------------------------------------------------------------------
	# Find a base type for a specific operation
	#-------------------------------------------------------------------------------------------------------------------
	def load_port_type_with_name operation
		port_types = @parsed_wsdl.port_types.clone
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
		message_name = remove_namespace(message_name)
		core_data_map = {}

		# Find the message
		@parsed_wsdl.messages.each do |message|
			# We found the message, now load all the input
			if message_name.eql?(remove_namespace(message['name']))

				message_children = message['children']
				parent_name = message_name
				unless (message_children.nil? and message_children.empty?)
					message_children.each do |message_child|

						unless is_base_type?(message_child)
							# Load data array from types map
							message_child_element = message_child['element']
							unless message_child_element
								message_child_element = message_child['type']
							end
							type_name = remove_namespace(message_child_element)
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

				break
			end
		end

		core_data_map
	end

	def is_base_type? type_node
		type = type_node['type']
		if type
			return is_xml_schema_type?(type)
		end

		false
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Removes namespace prefix if any
	#-------------------------------------------------------------------------------------------------------------------
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
		name_sought = remove_namespace(name_sought)

		data_types = {}
		children = []
		top_level_elements = @parsed_wsdl.types.clone
		                                       1
		# Start parse over the 'types' elements
		top_level_elements.each do |type_element|
			type_element_children = type_element['children']
			type_name = type_element['name']

			# If the base elements are sub-elements
			if (!type_element_children.nil? && !type_element_children.empty? && type_name =~ /#{name_sought}/)
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

						if @exclude_file_ops && is_file_type?(child['type'])
							next
						end

						# Try to load reference to enumeration if the type is not
						# a XML schema base type
						child_type = child['type']
						if (!child_type.nil? && !(is_xml_schema_type?(child_type)))
							# Change the type to an array of hash values
							# (:name, :type, :value)
							new_type = load_enumeration_data child_type
							if new_type
								child['type'] = new_type
							end
						end

						# TODO: recursively load other types.

						data_types[parent_name] << child
					elsif child['children']
						# Don't modify the base data structure
						child_children = child['children'].clone
						child_name = child['name']
						if (!child_name.nil? && !child_name.empty?)
							parent_name = child_name
						end

						if child_children.empty?
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
	# Builds and returns basic authentication header
	#-------------------------------------------------------------------------------------------------------------------
	def load_basic_auth
		basic_auth = {}
		basic_auth['Basic Authentication'] = []
		basic_auth['Basic Authentication'] << {'name' => 'Name', 'type' => 'string', 'nillable' => 'true'}
		basic_auth['Basic Authentication'] << {'name' => 'Password', 'type' => 'string', 'nillable' => 'true'}
		basic_auth
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Returns true iff the passed in type represent a file format
	#-------------------------------------------------------------------------------------------------------------------
	def is_file_type? type
		FILE_TYPES.each do |file_type|
			if type =~ /#{file_type}/
				return true
			end
		end

		false
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Parses over the 'types' map and loads all the enumerations that are part of the passed in name type.
	# The map construct is of the form {name => type_name, type => (string,int,etc), values => [array of vals] }
	#-------------------------------------------------------------------------------------------------------------------
	def load_enumeration_data type_name
		type_name = remove_namespace(type_name)

		# Iterate of the types table until we find the type name sought and the element_name is simpleType
		top_level_elements = @parsed_wsdl.types.clone

		# Start parse over the 'types' elements
		top_level_elements.each do |type_element|
			name = type_element['name']
			element_name = type_element['element_name']
			child_elements = type_element['children']

			if (!name.nil? && name.eql?(type_name) && element_name =~ /simpleType/)
				# We found what we are looking for, now define the
				input = {}
				input['name'] = name
				input['values'] = []
				child_elements.each do |child|
					element_name = child['element_name']
					if element_name
						case element_name
							when /enumeration/
								input['values'] << child['value']
							when /restriction/
								input['type'] = child['base']
						end
					end

					# Continue iteration over the children
					inner_child_elements = child['children']
					if inner_child_elements
						child_elements.concat inner_child_elements
					end
				end

				return input
			end

			# Keep adding the child elements
			if (!child_elements.nil? && !child_elements.empty?)
				top_level_elements.concat child_elements
			end
		end

		nil
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
	#
	#
	#-------------------------------------------------------------------------------------------------------------------
	def is_xml_schema_type? type
		type =~ /^#{@parsed_wsdl.xml_schema_qualifier}/
	end

end