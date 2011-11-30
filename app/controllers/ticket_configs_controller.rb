require File.expand_path(File.join(File.dirname(__FILE__), '../engine/modules/ticketing/clients/jira4_client'))
#require File.expand_path(File.join(File.dirname(__FILE__), '../engine/modules/ticketing/clients/remedy/remedy_client'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_parser'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_utility'))

#-----------------------------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------------------
class TicketConfigsController < ApplicationController
	respond_to :html

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def new
		# Parse the WSDL information.
		wsdl_file_name = params[:wsdl_file_name]
		if wsdl_file_name
			@wsdl_operations = get_wsdl_operations wsdl_file_name

			# Store this file name in the session for later use
			session[:wsdl_file_name]  = wsdl_file_name

			# Ensure the div is setup and open.
			@ticket_type = "Remedy"
			@show_ticket_client_div = true
		end

		load_default_models
		load_nexpose_user_list
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def edit
		@ticket_config = TicketConfig.find(params[:id])
		@ticket_type = get_ticket_type(@ticket_config.ticket_client_type)
		@ticket_mappings = @ticket_config.ticket_mapping
		@ticket_rules = @ticket_config.ticket_rule

		load_default_models
		load_nexpose_user_list
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def create
		if not create_test_ticket? and not wsdl_upload?
			@ticket_client = load_ticket_client_data
			@ticket_client.build_ticket_config(params[:ticket_config])

			if @ticket_client.save
				redirect_to '/added_modules'
			else
				load_default_models
				render :action => 'new'
			end
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def update
		if not create_test_ticket? and not wsdl_upload?
			@ticket_config = TicketConfig.find(params[:id])
			@ticket_client = @ticket_config.ticket_client
			ticket_client_update_params = load_ticket_client_data.attributes
			if @ticket_config.update_attributes(params[:ticket_config]) and @ticket_client.update_attributes(ticket_client_update_params)
				redirect_to '/added_modules'
			else
				load_default_models
				render :action => "edit"
			end
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def load_ticket_client_data
		ticket_client = nil
		case params[:ticket_client]
			when /Jira3/
				ticket_client = Jira3TicketConfig.new(Jira3TicketConfig.parse_model_params params[:jira3_config])
			when /Jira4/
				ticket_client = Jira4TicketConfig.new(Jira4TicketConfig.parse_model_params params[:jira4_config])
			when /Nexpose/
				ticket_client = NexposeTicketConfig.new(NexposeTicketConfig.parse_model_params params[:nexpose_config])
			when /Remedy/
				op_id = params[:remedy_ticket_op_id].chomp.to_i
				wsdl_file_name = session[:wsdl_file_name]
				operation = get_wsdl_operations(wsdl_file_name).keys[op_id]
				input_map = RemedyTicketConfig.parse_model_params(params, wsdl_file_name, operation)
				ticket_client = RemedyTicketConfig.new
				ticket_client.mappings = input_map
		end

		ticket_client
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def destroy
		@ticket_config = TicketConfig.find(params[:id])
		@ticket_config.destroy

		redirect_to :ticket_configs_url
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def create_test_ticket?
		if params[:commit] =~ /^Create/
			msg = 'Error in ticketing module'
			ticket_auth_data = params[:ticket_config]
			case params[:ticket_client]
				when /Jira3/
				when /Jira4/
					ticket_client_data = Jira4TicketConfig.parse_model_params params[:jira4_config]
					@jira4_ticket_client = Jira4TicketConfig.new ticket_client_data
					@auth_data = @jira4_ticket_client
					@ticket_type = 'Jira4x'
					@jira4_ticket_client.valid?
					jira4_client = Jira4Client.new ticket_client_data[:username], ticket_client_data[:password], ticket_client_data[:host], ticket_client_data[:port]
					ticket_mappings = TicketMapping.new params[:ticket_config][:ticket_mapping_attributes]
					msg = jira4_client.create_test_ticket ticket_client_data, ticket_mappings
				when /Nexpose/
					raise 'Cannot create a test ticket with Nexpose'
				when /Remedy/

			end

			if msg
				flash[:error] = msg
			else
				flash[:notice] = 'Ticket created successfully'
			end

			@show_ticket_client_div = true
			load_default_models
			load_nexpose_user_list
			render :action => 'new'
			true
		else
			false
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def wsdl_upload?
		if params[:commit] =~ /Parse/
			uploaded_io = params[:remedy_ticket_config][:wsdl]
			file_name = uploaded_io.original_filename
			File.open(Rails.root.join('public', 'uploads', file_name), 'w') do |file|
				file.write(uploaded_io.read)
			end

			redirect_to :action => "new", :wsdl_file_name => file_name
			true
		else
			false
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def load_nexpose_user_list
		@user_list = []
		nsc_configs = NscConfig.all

		unless nsc_configs.empty?
			@user_list = NSCConnectionManager.instance.get_user_array NscConfig.all[0].host
		end
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def load_default_models
		if @ticket_config.nil?
			@ticket_config = TicketConfig.new params[:ticket_config]
			@ticket_config.ticket_mapping = TicketMapping.new
			@ticket_config.ticket_rule = TicketRule.new
			@jira4_ticket_config = Jira4TicketConfig.new params[:jira4_ticket_config]
			@jira3_ticket_config = Jira3TicketConfig.new params[:jira3_ticket_config]
		end
		@remedy_ticket_config = RemedyTicketConfig.new params[:remedy_ticket_config]
	end

	#-------------------------------------------------------------------------------------------------------------------
	#
	#-------------------------------------------------------------------------------------------------------------------
	def get_wsdl_operations wsdl_file_name
		wsdl_doc = File.read(Rails.root.join('public', 'uploads', wsdl_file_name))
		parsed_wsdl = WSDLParser.parse wsdl_doc
		wsdl_util = WSDLUtil.new parsed_wsdl
		wsdl_util.get_soap_input_operations true
	end

	def get_ticket_type type

		@auth_data =  @ticket_config.ticket_client

		case type
			when /Jira3/
			 	@jira3_ticket_client = @ticket_config.ticket_client
				return 'Jira3x'
			when /Jira4/
				@jira4_ticket_client = @ticket_config.ticket_client
				return 'Jira4x'
			when /Remedy/
				return 'Remedy'
			else
				return 'Nexpose'
		end
	end

end
