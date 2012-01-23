require 'savon'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../net/wsdl_parser'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../net/wsdl_utility'))
require File.expand_path(File.join(File.dirname(__FILE__), 'ticket_client'))

#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# The interface used to communicate data to SOAP endpoints.
#
# == Author
# Christopher Lee, christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class SoapClient < TicketClient

  def initialize

  end

  #-------------------------------------------------------------------------------------------------------------------
  # Creates a test ticket within a soap endpoint.
  #-------------------------------------------------------------------------------------------------------------------
  def create_test_ticket ticket_data

  end

  def create_ticket ticket_data

    if ticket_data[:body]
      ticket_data[:body].each do |body_key, body_value|
        puts "Input for: #{body_key}"

        body_value.each do |inputs|
          if inputs[:minOccurs] and inputs[:minOccurs].to_i < 1
            puts "Skipping optional value: #{inputs[:name]}"
            next
          end

          puts "Enter a value for #{inputs[:name]} (type #{inputs[:type]})}: "
          user_input = gets
          soap_body_content[inputs[:name]] = user_input.chomp
        end
      end
    end

    # Headers need to be map of maps
    ticket_data[:header].each do |body_key, body_value|
      puts "Input for: #{body_key}"
      inner_map = {}

      body_value.each do |inputs|
        if inputs[:minOccurs] and inputs[:minOccurs].to_i < 1
          puts "Skipping optional value: #{inputs[:name]}"
          next
        end

        puts "Enter a value for #{inputs[:name]} (type #{inputs[:type]})}: "
        user_input = gets

        inner_map[inputs[:name]] = user_input.chomp
      end

      soap_header_content[body_key] = inner_map

    end

    client.request :get do
      soap.body = soap_body_content
      soap.header = soap_header_content
    end

  end


end

client = Savon::Client.new do
		wsdl.document = "/home/bperry/Documents/test.wsdl"
end

wsdl_parser = WSDLParser.parse client.wsdl.xml

wsdl_util = WSDLUtil.new wsdl_parser

actions = wsdl_util.get_soap_input_operations true

puts actions.inspect

#-------------------------------------------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------------------------------------------
=begin
begin
		client = Savon::Client.new do
			wsdl.document = File.expand_path("../../../../../user_data/Chris-Test-Web-Service.xml", __FILE__)
		end

		wsdl_parser = WSDLParser.parse client.wsdl.xml

		wsdl_util = WSDLUtil.new wsdl_parser

		#puts wsdl_parser.elements.inspect
		actions = wsdl_util.get_operations_and_parameters(true)["Get"]
		soap_body_content = {}
		soap_header_content = {}

		actions[:body].each do |body_key, body_value|
			puts "Input for: #{body_key}"

			body_value.each do |inputs|
				if inputs[:minOccurs] and inputs[:minOccurs].to_i < 1
					puts "Skipping optional value: #{inputs[:name]}"
					next
				end

				puts "Enter a value for #{inputs[:name]} (type #{inputs[:type]})}: "
				user_input = gets
				soap_body_content[inputs[:name]] = user_input.chomp
			end
		end

		# Headers need to be map of maps
		actions[:header].each do |body_key, body_value|
			puts "Input for: #{body_key}"
			inner_map = {}

			body_value.each do |inputs|
				if inputs[:minOccurs] and inputs[:minOccurs].to_i < 1
					puts "Skipping optional value: #{inputs[:name]}"
					next
				end

				puts "Enter a value for #{inputs[:name]} (type #{inputs[:type]})}: "
				user_input = gets

				inner_map[inputs[:name]] = user_input.chomp
			end

			soap_header_content[body_key] = inner_map

		end

		puts soap_body_content.inspect
		puts soap_header_content.inspect

		begin
			response = client.request :get do
				soap.body = soap_body_content
				soap.header = soap_header_content
			end

		rescue Exception => e
			puts "**** RESPONSE ****"
			puts e.message
		end


		actions.each do |action|
			key = action.keys[0].to_s
			if key.eql? "Create"
				puts action[key].inspect
			end

		end

	end
=end
