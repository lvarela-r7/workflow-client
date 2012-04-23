require File.expand_path(File.join(File.dirname(__FILE__), '../engine/misc/model_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/misc/util'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_parser'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_utility'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/misc/cache'))

#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Handles SOAP validation
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class SOAPValidator < ActiveModel::Validator

  def validate soap_record
      mappings = soap_record.mappings

      # Parse the port type and operation.
      operation_def = mappings[:operation]
      op_parts = operation_def.split("|")
      port_type = op_parts[0]
      operation = op_parts[1]

      wsdl_file_name = mappings[:wsdl_file_name]
      cache = Cache.instance

      if cache.has_in_cache?(wsdl_file_name)
         wsdl_operations = cache.get wsdl_file_name
      else
        wsdl_doc = Util.get_public_uploaded_file wsdl_file_name
        parsed_wsdl = WSDLParser.parse wsdl_doc
        wsdl_util = WSDLUtil.new parsed_wsdl
        wsdl_operations = wsdl_util.get_soap_input_operations true
        cache.add_to_cache(wsdl_file_name, wsdl_operations)
      end

      # From the WSDL ops get the header and operations array
      # that contain info about the different data ops.
      op_hash = wsdl_operations[port_type]['operations'][operation]
      op_array = []
      op_headers = nil
      op_hash.each do |key, value|
        if 'headers'.eql?(key)
          op_headers = value
        else
           op_array = op_array.concat value
        end
      end

      # TODO: Skip header validation for now
      # Gather header data

      # For each mapping item do required validation and
      # type validation.

      mappings[:body].each do |key, value|
        # Skip headers
        if 'header'.eql?(key) and value.kind_of?(Hash)
          next
        end

        # TODO: Need to find a quicker way to do this.
        # TODO: Add more validation as we go along
        op_array.each do |param|
          if key.eql?(param['name']) && param['type']

            # Validation for numeric types
            if param['type'] =~ /int|long|short|byte/
              # Validate the value is a number
              unless (value.to_s.chomp =~ /^\d+$/)
                soap_record.errors[:base] << "The field #{key} requires an integer."
              end

            # Validation for date (format: YYYY-MM-DD)
            elsif param['type'] =~ /date/
              unless (value =~ /(\d{4})-(\d{2})-(\d{2})/)
                 soap_record.errors[:base] << "The field #{key} requires a date (format : YYYY-MM-DD)"
              end
            end

            # Validation for dateTime (format: YYYY-MM-DDThh:mm:ss)
            elsif param['type'] =~ /dateTime/
              unless (value =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/)
                 soap_record.errors[:base] << "The field #{key} requires a dateTime (format : YYYY-MM-DDThh:mm:ss)"
              end
            end
          end
      end


  end
end

#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# The SOAP model definition
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class SOAPTicketConfig < ActiveRecord::Base

  validates_with SOAPValidator

	serialize :mappings, Hash

	has_one :ticket_config, :as => :ticket_client

  validate do |client|
		if client.ticket_config
			next if client.ticket_config.valid?
			client.ticket_config.errors.full_messages.each do |msg|
				errors.add_to_base msg
      end
    end
  end

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

    input = {}

    input[:body] = ModelHelper.flatten_map(params[key])

		# Add the operation and the file name
		input[:wsdl_file_name] = wsdl_file_name
		input[:operation] = operation
    input[:headers] = header_input
    input[:selected_soap_id] = op_id
		input
  end

end
