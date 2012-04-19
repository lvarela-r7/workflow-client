require_relative '../../../net/wsdl_parser'
require_relative '../../../net/wsdl_utility'

require 'savon'
require 'rexml/document'
require File.expand_path(File.join(File.dirname(__FILE__), 'ticket_client'))

class GenericSoapClient < TicketClient

  attr_accessor :actions

  def initialize ticket_data
    #@ticket_data = ticket_data
  end

  def configure config
    @client = Savon::Client.new do
      wsdl.document = File.expand_path(File.join(File.dirname(__FILE__), "../../../../../public/uploads/" + config.mappings[:wsdl_file_name]))
    end

    @parser = WSDLParser.parse @client.wsdl.xml

    op = config.mappings[:operation].split '|'

    #p @parser.inspect

    #this is brittle
    @parser.services.each do |service|
      service["children"].each do |child|
        next if child["name"] != op[0]
        child["children"].each do |c|
          if c["name"] =~ /address/
            @endpoint = c["location"]
          end
        end
      end
    end

    @target_namespace = @parser.wsdl_definitions["targetNamespace"]

    @wsdl_util = WSDLUtil.new @parser
    @actions = @wsdl_util.get_soap_input_operations true
  end

  def create_ticket ticket_data 
    raise "No ticket body" if not ticket_data[:body]

    resp = @client.request :urn, ticket_data[:operation] do
      http.headers["SOAPAction"] = @endpoint
      soap.input = [ "urn:" + ticket_data[:operation], {} ]
      soap.header = ticket_data[:headers] || {}
      soap.body = ticket_data[:body]
      #soap.element_form_default = :unqualified
      #soap.namespace = @target_namespace
    end

  end
end
