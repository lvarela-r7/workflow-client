require 'rubygems'
require 'nokogiri'

#-----------------------------------------------------------------------------------------------------------------------
# Class used to parse a WSDL document.
#
# @author: Christopher Lee, christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

class WSDLParser < Nokogiri::XML::SAX::Document

  # PARSE STRATEGY
  # For each major type needed the base data type is an ARRAY which
  # will store a map of attributes. Nested elements will be marked
  # with a "children" tag recursively.  Children will therefore
  # be an array of the attributes in that child and then another
  # "children" attribute if there are more sub-elements.

  # TOP LEVEL ELEMENTS
  # wsdl:types => data types used by WS
  # wsdl:messages => Define the data elements, can contain one or more parts. ie: function parameters
  # wsdl:portType => operations that can be performed by an endpoint.
  # wsdl:binding
  # wsdl:service

  attr_reader :port_types, :types, :messages, :bindings, :services,
              :wsdl_definitions, :xml_schema_qualifier, :wsdl_version

  WSDL_SCHEMA_URL = ["^http:\/\/schemas\.xmlsoap\.org\/wsdl[\/]{0,1}$", "^http:\/\/www\.w3\.org\/ns\/wsdl[\/]{0,1}$"]
  XML_SCHEMA_URL = "^http:\/\/www\.w3\.org\/2001\/XMLSchema[\/]{0,1}$"

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
  # Initialize the base array types
  #-------------------------------------------------------------------------------------------------------------------
  def initialize
    @port_types = []
    @types = []
    @messages = []
    @bindings = []
    @services = []
    @wsdl_definitions = {}

    @in_types = false
    @in_port_types = false
    @in_message = false
    @in_bindings = false
    @in_services = false
    @in_wsdl_definitions = false

    # Use this default if wsdl:definitions tag not found
    @wsdl_namespace = ''
    @xml_schema_qualifier = ''
    @wsdl_version = 0

    @depth = 0

    super
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def end_element name
    set_in_block name, false
    @depth = @depth - 1
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def start_element name, attrs = []
    set_in_block name, true
    if @in_types
      add_data name, attrs, @types
    elsif @in_message
      add_data name, attrs, @messages
    elsif @in_port_types
      add_data name, attrs, @port_types
    elsif @in_bindings
      add_data name, attrs, @bindings
    elsif @in_services
      add_data name, attrs, @services
    elsif @in_wsdl_definitions
      parse_wsdl_definitions attrs
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def characters string

  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def parse_wsdl_definitions attrs
    attrs.each do |attr_array|
      key = attr_array[0].to_s.chomp
      value = attr_array[1].to_s.chomp
      if key =~ /xmlns:/
        if is_wsdl_url?(value)
          @wsdl_namespace = key.split(':')[1]
        elsif value =~ /#{XML_SCHEMA_URL}/
          @xml_schema_qualifier = key.split(':')[1]
        end
      end

      @wsdl_definitions[key] = value
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def is_wsdl_url? input
    WSDL_SCHEMA_URL.each_index do |index|
      if input =~ /#{WSDL_SCHEMA_URL[index]}/
        case index
          when 0
            @wsdl_version = 1.2
          when 1
            @wsdl_version = 2.0
        end
        return true
      end
    end

    false
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def set_in_block name, is_in
    case name
      # Parse out the namespaces
      when /.*:definitions/
        @in_wsdl_definitions = is_in
      when /#{@wsdl_namespace}:portType/
        @in_port_types = is_in
      when /#{@wsdl_namespace}:types/
        @in_types = is_in
      when /#{@wsdl_namespace}:message/
        @in_message = is_in
      when /#{@wsdl_namespace}:binding/
        @in_bindings = is_in
      when /#{@wsdl_namespace}:service/
        @in_services = is_in
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def add_data element_name, attributes, element_array
    last_map = element_array.last

    if last_map.nil? or @depth == 0
      last_map = {}
      last_map['element_name'] = element_name.to_s.chomp
      attributes.each do |attribute|
        last_map[attribute[0].to_s.chomp] = attribute[1].to_s.chomp
      end
      element_array << last_map
    else
      # Find current element
      starting_depth = @depth - 1
      while starting_depth > 0
        last_child = last_map['children'].last
        unless last_child.nil?
          last_map = last_child
        end
        starting_depth = starting_depth - 1
      end

      if (last_map['children'].nil?)
        last_map['children'] = []
      end

      next_map = {}
      next_map['element_name'] = element_name.to_s.chomp
      attributes.each do |attribute|
        next_map[attribute[0].to_s.chomp] = attribute[1].to_s.chomp
      end
      last_map['children'] << next_map
    end

    @depth = @depth + 1
  end

end
