class WSDLParser < Nokogiri::XML::SAX::Document


	# types => data types used by WS
	# messages => Define the data elements, can contain one or more parts. ie: function parameters
	# operations => (portType) operations that can be performed by an endpoint.
	#
	attr_reader :operations, :types, :elements, :documentation, :messages, :headers

	@in_types = false
	@in_operation = false
	@in_message = false
	@in_type_block = false

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def self.parse doc
		instance = WSDLParser.new
		parser = Nokogiri::XML::SAX::Parser.new instance
		parser.parse doc
		instance
	end

	###################
	# PRIVATE METHODS #
	###################
	private

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def initialize
		@operations = {}
		@types = {}
		@elements = {}
		@messages = {}
		@headers = {}
		@documentation = ""
		@last_seen_operation_name = ""

		super
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def end_element name
		set_in_block name, false

		if not name =~ /types/i and name =~ /type/i
			@in_type_block = false
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def start_element name, attrs = []
		set_in_block name, true
		if @in_types
			parse_types name, attrs
		elsif @in_message
			parse_message name, attrs
		elsif @in_operation
			parse_operation name, attrs
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def characters string
	   if @in_document
		   @documentation = string.chomp
	   end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def set_in_block name, is_in
		case name
			when /documentation/
				@in_document = is_in
			when /types/
				@in_types = is_in
			when /message/
				@in_message = is_in
			when /wsdl:operation/
				@in_operation = is_in
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Parses out the WSDL types.
	#-------------------------------------------------------------------------------------------------------------------
	def parse_types name, attrs = []
	   	# skip schema  and types tag
		if name.eql? 'xsd:schema' or name =~ /types/
			return
		end

		if name =~ /element/ and not @in_type_block
			add_element attrs
		elsif name =~ /type/i
			@in_type_block = true
			tag_name = get_attr attrs, "name"
			@types[tag_name] = []
		elsif @in_type_block
			if name =~ /restriction/ or name =~ /sequence/
				@types[@types.keys.last] << ["parent-type", name]
			end

			if attrs and not attrs.empty?
				@types[@types.keys.last] << attrs.flatten
			end
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def parse_message name, attrs
		if name =~ /message/
			@messages[get_attr(attrs, "name")] = []
		elsif name =~ /part/
			input = [name, get_attr(attrs, "element")]
			@messages[@messages.keys.last] << input
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def parse_operation name, attrs
		op_name = get_attr(attrs, "name")
		message = get_attr(attrs, "message")
		if op_name and not op_name.to_s.empty?
			@last_seen_operation_name = op_name
		end

		if not @last_seen_operation_name.to_s.empty?
			if name =~ /operation/ and not @operations[@last_seen_operation_name]
				@operations[@last_seen_operation_name] = []
			elsif name =~ /input/
				if message
					@operations[@last_seen_operation_name] << ["message", message]
				end
			elsif name =~ /header/
				unless @headers[@last_seen_operation_name]
					@headers[@last_seen_operation_name] = []
				end
				if message
					@headers[@last_seen_operation_name] << message
				end
			end
		 end
	end

	#-------------------------------------------------------------------------------------------------------------------
  	# Parses out SOAP elements.
	#-------------------------------------------------------------------------------------------------------------------
	def add_element attrs = []
		# Just parse out the name and associated type
		name = ""
		type = ""
		attrs.each do |attr|
			case attr[0].to_s
				when /name/
					name = attr[1].to_s
				when /type/
					type = attr[1].to_s
			end
		end

		@elements[name] = type
	end

	#-------------------------------------------------------------------------------------------------------------------
	# Returns the attribute value with name @name
	#-------------------------------------------------------------------------------------------------------------------
	def get_attr attrs, name

		attrs.each do |attr|
			if attr[0].eql? name.to_s
				return attr[1]
			end
		end

		nil
	end
end