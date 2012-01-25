require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/model_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/util'))

class SOAPValidator < ActiveModel::Validator

  def validate soap_record
      mappings = soap_record.mappings
      wsdl_file = mappings['wsdl_file_name']

      puts mappings
  end
end

class SOAPTicketConfig < ActiveRecord::Base
  include ModelHelper

  validates_with SOAPValidator

	serialize :mappings, Hash
	has_one :ticket_config, :as => :ticket_client

  #
  # The SOAP headers are stored in "soap_config_header_$Id"
  # The body is stored in "soap_config_$Id"
  #
	def self.parse_model_params params, wsdl_file_name, operation
		op_id = params[:soap_ticket_op_id]

    # Parse out the headers
    header_key = "soap_config_header_#{op_id}"
    header_input = params[header_key]

    # Parse out the SOAP body content
		key = "soap_config_#{op_id}"
    input = ModelHelper.flatten_map(params[key])

		# Add the operation and the file name
		input[:wsdl_file_name] = wsdl_file_name
		input[:operation] = operation
    input[:headers] = header_input
    input[:selected_soap_id] = op_id
		input
  end

end
