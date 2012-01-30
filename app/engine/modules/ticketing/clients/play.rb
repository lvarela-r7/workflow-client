require_relative 'soap_client'
require_relative '../../../net/wsdl_parser'
require_relative '../../../net/wsdl_utility_jira'

require 'savon'
require 'rexml/document'

#this is the url of the WSDL for url
#fo rme it is http://127.0.0.1:8080/rpc/soap/jirasoapservice-v2?wsdl
doc = gets

client = Savon::Client.new do
    wsdl.document = doc
end

parser = WSDLParser.parse client.wsdl.xml

wsdl_util = WSDLUtil.new parser

actions = wsdl_util.get_soap_input_operations true

ticket_data = {}

puts "Current API: #{actions.first[0]}"

args = actions.first[1]

ticket_data["headers"] = {}

args["headers"].each do |header_key, header_value|
  puts "I need some info for #{header_key}"
  ticket_data["headers"][header_key] = {}

  header_value.each do |hk, hv|
    hv.each do |k|
      puts "I need information regarding \"#{k["name"]}\""
      tmp = gets
      ticket_data["headers"][header_key][k["name"]] = tmp.chomp
    end
  end

end

ticket_data["operations"] = {}

args["operations"].each do |op|
  next if op[0] != "login"
  p "I need you JIRA credentials. Username first, password second."
  op[1].each do |vals|
    next if vals[0] == "headers"
    vals[1].each do |val|
      next if val["name"] == nil
      p val["name"]
      tmp = gets
      ticket_data["operations"][val["name"]] = tmp.chomp
    end
  end
end

#log the user in, get auth token
response = client.request :login do
  soap.body = ticket_data["operations"]
  soap.header = ticket_data["headers"]
end

auth_token = response.body[:login_response][:login_return]

p "Please copy the auth token below, you will need it for the next request."
p auth_token
gets

#print out all methods we can use, except login and logout since we do that for the user
args["operations"].each do |op|
  next if op[0] == "login"
  next if op[0] == "logout"
  p op[0]
end

user_op = gets

ticket_data["operations"] = {}
i = 0 #the wsdl parser doesn't parse something correctly, this is a workaround

#find the operation the user wants
args["operations"].each do |op|
  next if op[0] != user_op.chomp

  op[1].each do |vals|
    next if vals[0] == "headers"

    if i == 0
      p "I need some info for a #{vals[0]}"
      vals[1].each do |val|
        next if val["name"] == nil

        p val["name"] + " and type: " + val["type"]
        tmp = gets
        ticket_data["operations"][val["name"]] = tmp.chomp
        i = 1
      end
    else
      p "I need some info for a #{vals[0]}"
      ticket_data["operations"][:"in#{i}"] = {}
      vals[1].each do |val|
        next if val["name"] == nil

        p val["name"] + " and type: " + val["type"]
        tmp = gets

        tmp.chomp!
        #don't add elements for empty data
        ticket_data["operations"][:"in#{i}"][val["name"]] = tmp if not tmp.empty?
      end
      i = i + 1
    end
  end
end

#make op request
response = client.request user_op do
  soap.body = ticket_data["operations"]
  soap.header = ticket_data["headers"]
end 

ticket_data["operations"] = {}

args["operations"].each do |op|
  next if op[0] != "logout"

  op[1].each do |vals|
    next if vals[0] == "headers"

    p "Logging out..."
    vals[1].each do |val|
      ticket_data["operations"][val["name"]] = auth_token
    end
  end
end

response = client.request :logout do
  soap.body = ticket_data["operations"]
  soap.header = ticket_data["headers"]
end
