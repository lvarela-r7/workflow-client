require 'savon'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../net/wsdl_parser'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../../net/wsdl_utility'))
require File.expand_path(File.join(File.dirname(__FILE__), 'ticket_client'))

#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# The interface used to communicate data to SOAP endpoints.
#
# == Author
# Brandon Perry Brandon_Perry@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class SOAPClient < TicketClient

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

    @soap_body_content = {}
    @method = method
    @endpoint = endpoint
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


=begin
auth_data = {}

auth_data[:username] = "Test"
auth_data[:password] = "password"
auth_data[:authentication] = "Basic"
auth_data[:locale] = "en_US"
auth_data[:timezone] = "CST"

soap_client = SoapClient.new "create", auth_data, "http://127.0.0.1:8088/mockPortSoapBinding"
soap_client.create_test_ticket



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


=begin
Excerpt from working SOAP exec

require_relative 'wsdl_parser'
require_relative 'wsdl_utility'

require 'rubygems'
require 'nokogiri'
require 'savon'
require 'rexml/document'

doc = './Childens_Hospital_WSDL.xml'

client = Savon::Client.new do
  wsdl.document = doc
end

parser = WSDLParser.parse client.wsdl.xml

wutil = WSDLUtil.new parser

actions = wutil.get_soap_input_operations true

p "Using SOAP API: " + actions.first[0]

args =  actions.first[1]

ticket_data = {}
ticket_data[:headers] = {}
ticket_data[:headers]["Basic Authentication"] = {}

p "Do you want to use basic authentication when posting your information? (Y/N)"
use_basic_auth = gets

if use_basic_auth =~ /^y$/i
  args["headers"]["Basic Authentication"].each do |val|
    val[1].each do |v|
      p "I need your #{v["name"]}"
      tmp = gets
      ticket_data[:headers]["Basic Authentication"][v["name"]] = tmp.chomp
    end
  end
end

ticket_data["operations"] = {}

p ""
p ""
p "Current available methods:"
args["operations"].each do |op|
  p op[0]
end

p ""
p "Which method do you want to instantiate?"
op = gets

op.chomp!
soap_action = ""

parser.bindings.each do |parser_child|
  parser_child["children"].each do |child|
    next if child["name"] != op

    child["children"].each do |cc|
      next if cc["element_name"] != "soap:operation"
      soap_action = cc["soapAction"]
    end
  end
end

raise "No soap action found" if soap_action.empty?

ticket_data["operations"][op] = {}


args["operations"].each do |o|
  next if o[0] != op

  o[1].each do |as|
    as[1].each do |arg|
      next if arg["name"] == nil

      optional = (arg["minOccurs"] == "0" ? true : false)

      p "I need some info regarding the #{arg["name"]}" + (optional ? " (Optional)" : "")

      if arg["type"]["name"] == nil
        val = gets
        val.chomp!
      else
        i = 1
        arg["type"]["values"].each do |value|
          p "#{i}. #{value}"
          i = i + 1
        end

        p "Which number above describes your #{arg["name"]}?"
        num = gets
        num.chomp!

        while num.empty? or num.to_i == 0
          p "I need a number to correspond to your #{arg["name"]}."
          num = gets
          num.chomp?
        end

        val = arg["type"]["values"][num.to_i - 1]

        while val.nil?
          p "I need a number that corresponds to an above option."
          num = gets
          num.chomp!

          while num.empty? or num.to_i == 0
            p "I need a number that corresponds to your #{arg["name"]}."
            num = gets
            num.chomp!
          end

          val = arg["type"]["values"][num.to_i - 1]
        end

      end

      while !optional and (val.nil? or val.empty?)
        p "Value not optional. I need some info regarding the #{arg["name"]}"
        val = gets
        val.chomp!
      end

      ticket_data["operations"][op][arg["name"]] = val if !val.empty?
    end
  end
end

#$stdout.reopen("stdout.txt", "a")
#$stderr.reopen("stderr.txt", "a")

puts ticket_data.inspect
response = client.request op do
  soap.body = ticket_data["operations"][op]
  soap.header = ticket_data["headers"]
  http.headers["SOAPAction"] = soap_action
end


=end
