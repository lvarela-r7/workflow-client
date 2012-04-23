require_relative './generic_soap_client'

p "Where is the wsdl?"
wsdl_path = gets

client = GenericSoapClient.new wsdl_path

ticket_data = {}
ticket_data["headers"] = {}
ticket_data["body"] = {}


