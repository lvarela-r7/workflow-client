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

<<<<<<< HEAD
    attr_accessor :soap_body_content

  def initialize method, auth_data, endpoint
    @client = Savon::Client.new do
      wsdl.document = "/home/bperry/Desktop/Chris-Test-Web-Service.xml"
    end

    @soap_header_content = {}
    @soap_header_content["urn:AuthenticationInfo"] = {}

    @soap_header_content["urn:AuthenticationInfo"]["urn:userName"] = auth_data[:username]
    @soap_header_content["urn:AuthenticationInfo"]["urn:password"] = auth_data[:password]
    @soap_header_content["urn:AuthenticationInfo"]["urn:authentication"] = auth_data[:auth_type]
    @soap_header_content["urn:AuthenticationInfo"]["urn:locale"] = auth_data[:locale]
    @soap_header_content["urn:AuthenticationInfo"]["urn:timeZone"] = auth_data[:timezone]
=======
  def initialize
>>>>>>> ef1f217ac525ad8c046a3e16f3e683c95c89420a

    @soap_body_content = {}
    @method = method
    @endpoint = endpoint
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Creates a test ticket within a soap endpoint.
  #-------------------------------------------------------------------------------------------------------------------
  def create_test_ticket
    ticket_data = {}

    ticket_data[:submitter] = "Brandon Perry"
    ticket_data[:assigned_to] = "Chris Lee"
    ticket_data[:status] = "New"
    ticket_data[:short_description] = "A short description about the ticket"
    ticket_data[:license_type] = "Uber Pro Platinum with extra Awesome"
    ticket_data[:qualifier] = "PhD"
    ticket_data[:number_of_licenses] = "Sagan"
    ticket_data[:key] = "m3t4spl01t+n3xp0s3=4w350m3"
    ticket_data[:expiration_date] = "9/9/9999"
    ticket_data[:license_key] = "p1r4t3m0nk3y"
    ticket_data[:host_id] = "192.168.1.111"
    ticket_data[:overwrite_license] = "1"
    ticket_data[:exportimportattach_attachment_name] = "Attachment #1"
    ticket_data[:exportimportattach_attachment_data] = "qwertyuiopasdfghjklzxcbnm"
    ticket_data[:exportimportattach_attachment_orig_size] = "123"
    ticket_data[:produseattachment_attachment_name] = "Attachment #2"
    ticket_data[:produseattachment_attachment_data] = "mnbvcxzlkjhgfdsapoiuytrewq"
    ticket_data[:produseattachment_attachment_orig_size] = "456"
    ticket_data[:z_temp_integer] = "1337"

    insert_ticket ticket_data
    
  end

  def insert_ticket ticket_data
    @soap_body_content["urn:submitter"] = ticket_data[:submitter]
    @soap_body_content["urn:assignedTo"] = ticket_data[:assigned_to]
    @soap_body_content["urn:status"] = ticket_data[:status]
    @soap_body_content["urn:shortDescription"] = ticket_data[:short_description]
    @soap_body_content["urn:licenseType"] = ticket_data[:license_type]
    @soap_body_content["urn:qualifier"] = ticket_data[:qualifier]
    @soap_body_content["urn:numberOfLicenses"] = ticket_data[:number_of_licenses]
    @soap_body_content["urn:key"] = ticket_data[:key]
    @soap_body_content["urn:expirationDate"] = ticket_data[:expiration_date]
    @soap_body_content["urn:licenseKey"] = ticket_data[:license_key]
    @soap_body_content["urn:hostID"] = ticket_data[:host_id]
    @soap_body_content["urn:overwriteLicense"] = ticket_data[:overwrite_license]
    @soap_body_content["urn:exportimportattachAttachmentName"] = ticket_data[:exportimportattach_attachment_name]
    @soap_body_content["urn:exportimportattachAttachmentOrigSize"] = ticket_data[:exportimportattach_attachment_orig_size]
    @soap_body_content["urn:exportimportattachAttachmentData"] = ticket_data[:exportimportattach_attachment_data]
    @soap_body_content["urn:produseattachmentAttachmentName"] = ticket_data[:produseattachment_attachment_name]
    @soap_body_content["urn:produseattachmentAttachmentOrigSize"] = ticket_data[:produseattachment_attachment_name]
    @soap_body_content["urn:produseattachmentAttachmentData"] = ticket_data[:produseattachment_attachment_data]
    @soap_body_content["urn:zTempInteger"] = ticket_data[:z_temp_integer]

    puts @soap_body_content.inspect
    puts @soap_header_content.inspect

    body = @soap_body_content
    header = @soap_header_content

    response = @client.request "Create" do
      http.headers["SOAPAction"] = @endpoint
      soap.input = [ "urn:Create", {} ]
      soap.header = header
      soap.body = body
      soap.namespaces["xmlns:urn"] = "urn:Chris-Test-Web-Service"

      puts soap.body.inspect
      puts soap.header.inspect
    end
  end
  
  def update_ticket

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

auth_data = {}

auth_data[:username] = "Test"
auth_data[:password] = "password"
auth_data[:authentication] = "Basic"
auth_data[:locale] = "en_US"
auth_data[:timezone] = "CST"

soap_client = SoapClient.new "create", auth_data, "http://127.0.0.1:8088/mockPortSoapBinding"
soap_client.create_test_ticket


=begin
client = Savon::Client.new do
    #wsdl.endpoint = "http://127.0.0.1:8088/mockPortSoapBinding"
		wsdl.document = "/home/bperry/Desktop/Chris-Test-Web-Service.xml"
    #wsdl.namespace = "http://127.0.0.1:8088/mockPortSoapBinding"
end

soap_body_content = {}
soap_header_content = {}

method = gets

soap_header_content["urn:AuthenticationInfo"] = {}

soap_header_content["urn:AuthenticationInfo"]["urn:userName"] = "testUser"
soap_header_content["urn:AuthenticationInfo"]["urn:password"] = "testPassword1!"
soap_header_content["urn:AuthenticationInfo"]["urn:authentication"] = "test auth value"
soap_header_content["urn:AuthenticationInfo"]["urn:locale"] = "en_US"
soap_header_content["urn:AuthenticationInfo"]["urn:timeZone"] = "CST"

if method =~ /^create$/i
  soap_body_content["urn:submitter"] = "Brandon Perry"
  soap_body_content["urn:assignedTo"] = "Chris Lee"
  soap_body_content["urn:status"] = "New"
  soap_body_content["urn:shortDescription"] = "A short description"
  soap_body_content["urn:licenseType"] = "uber pro platinum"
  soap_body_content["urn:qualifier"] = "blah"
  soap_body_content["urn:numberOfLicenses"] = "1000"
  soap_body_content["urn:key"] = "skeleton"
  soap_body_content["urn:expirationDate"] = "01/31/1989"
  soap_body_content["urn:hostID"] = "fdsafdast4545"
  soap_body_content["urn:licenseKey"] = "m3t4spl01t+n3xp053=4w350m3"
  soap_body_content["urn:overwriteLicense"] = "100"
  soap_body_content["urn:exportimportattachAttachmentName"] = "attachment name"
  soap_body_content["urn:exportimportattachAttachmentData"] = "qwertyasdfzxcv"
  soap_body_content["urn:exportimportattachAttachmentOrigSize"] = "1"
  soap_body_content["urn:produseattachmentAttachmentName"] = "some other name"
  soap_body_content["urn:produseattachmentAttachmentData"] = "more data"
  soap_body_content["urn:produseattachmentAttachmentOrigSize"] = "5"
  soap_body_content["urn:zTempInteger"] = "1337"

elsif method =~ /^get$/i
  soap_body_content["urn:requestID"] = "blah"

elsif method =~ /^insert$/i
  #ap_body_content["urn:
end

puts soap_header_content.inspect
puts soap_body_content.inspect

if method =~ /^create$/i
  response = client.request "Create" do
    soap.input = [ "urn:Create",{ }]
    soap.body = soap_body_content
    soap.header = soap_header_content
    soap.namespaces["xmlns:urn"] = "urn:Chris-Test-Web-Service"
    http.headers["SOAPAction"] = '"http://127.0.0.1:8088/mockportSoapBinding"'
  end
elsif method =~ /^get$/i
  response = client.request "Get" do
    soap.input = [ "urn:Get",{ }]
    soap.body = soap_body_content
    soap.header = soap_header_content
    http.headers["SOAPAction"] = '"http://127.0.0.1:8088/mockPortSoapBinding"'
    soap.namespaces["xmlns:urn"] = "urn:Chris-Test-Web-Service"
  end
end

#wsdl_parser = WSDLParser.parse client.wsdl.xml

#wsdl_util = WSDLUtil.new wsdl_parser

#actions = wsdl_util.get_soap_input_operations true

#puts actions.inspect

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
