require File.expand_path(File.join(File.dirname(__FILE__), '../engine/modules/ticketing/clients/jira4_client'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_parser'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_utility'))
require File.expand_path(File.join(File.dirname(__FILE__), '../engine/net/wsdl_parse_error'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/util'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/cache'))

#-----------------------------------------------------------------------------------------------------------------------
# Handles ticket configuration
#
# @author: Christopher Lee
#-----------------------------------------------------------------------------------------------------------------------
class TicketConfigsController < ApplicationController
  include Util
  respond_to :html

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def new
    # If a WSDL was defined
    # Parse the WSDL information.
    wsdl_file_name = params[:wsdl_file_name]
    if wsdl_file_name

      begin
        load_wsdl_ops wsdl_file_name
      rescue WSDLParseError => wsdl_error
        # Set the error and reload
        flash[:error] = wsdl_error.to_s
        load_defaults
        render 'new'
        return
      end

      # Store this file name in the session for later use
      session[:wsdl_file_name] = wsdl_file_name

      # Ensure the div is setup and open.
      @ticket_type = "SOAP supported"
      @show_ticket_client_div = true
    end


    load_defaults
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def edit
    @ticket_config = TicketConfig.find(params[:id])
    @ticket_type = get_ticket_type(@ticket_config.ticket_client_type)
    @ticket_mappings = @ticket_config.ticket_mapping
    @ticket_rules = @ticket_config.ticket_rule

    load_defaults
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Saves a new ticket configuration OR fires off a test ticket to the server OR uploads WSDL data.
  #-------------------------------------------------------------------------------------------------------------------
  def create
    if not create_test_ticket? and not wsdl_upload?
      @ticket_client = load_ticket_client_data
      @ticket_client.build_ticket_config(params[:ticket_config])

      if @ticket_client.save
        redirect_to '/added_modules'
      else
        load_defaults
        render 'new'
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

  private
  ###################
  # PRIVATE METHODS #
  ###################

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def load_defaults
    load_default_models
    load_nexpose_user_list
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def load_ticket_client_data
    ticket_client = nil
    case params[:ticket_client]
      when /Jira3/
        ticket_client = Jira3TicketConfig.new(Jira3TicketConfig.parse_model_params params[:jira3_config])
        @ticket_type = "Jira3x"
      when /Jira4/
        ticket_client = Jira4TicketConfig.new(Jira4TicketConfig.parse_model_params params[:jira4_config])
         @ticket_type = "Jira4x"
      when /Nexpose/
        @ticket_type = "Nexpose"
        ticket_client = NexposeTicketConfig.new(NexposeTicketConfig.parse_model_params params[:nexpose_config])
      when /^SOAP/
        @selected_soap_op_id = params[:soap_ticket_op_id].chomp.to_i
        wsdl_file_name = session[:wsdl_file_name]

        # Load the WSDL objects
        load_wsdl_ops wsdl_file_name

        @operation = @wsdl_id_op_map.rassoc(@selected_soap_op_id)[0]
        @input_map = SOAPTicketConfig.parse_model_params(params, wsdl_file_name, @operation)
        ticket_client = SOAPTicketConfig.new
        ticket_client.mappings = @input_map
        @ticket_type = "SOAP supported"
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
        when /jira3/i
        when /jira4/i
          ticket_client_data = Jira4TicketConfig.parse_model_params params[:jira4_config]
          @jira4_ticket_config = Jira4TicketConfig.new ticket_client_data
          @ticket_type = 'Jira4x'
          @jira4_ticket_config.valid?
          jira4_client = Jira4Client.new ticket_client_data[:username], ticket_client_data[:password], ticket_client_data[:host], ticket_client_data[:port]
          ticket_mappings = TicketMapping.new params[:ticket_config][:ticket_mapping_attributes]
          msg = jira4_client.create_test_ticket ticket_client_data, ticket_mappings
        when /nexpose/i
          raise 'Cannot create a test ticket with Nexpose'
        when /soap/i
          @ticket_type = "SOAP supported"
      end

      if msg
        flash[:error] = msg
      else
        flash[:notice] = 'Ticket created successfully'
      end

      @show_ticket_client_div = true
      load_defaults
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
      uploaded_io = params[:ticket_config][:wsdl]
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
      @ticket_mappings = @ticket_config.ticket_mapping
      @ticket_rules = @ticket_config.ticket_rule
      @ticket_config.ticket_mapping = TicketMapping.new
      @ticket_config.ticket_rule = TicketRule.new
      @jira4_ticket_config = Jira4TicketConfig.new params[:jira4_config]
      @jira3_ticket_config = Jira3TicketConfig.new params[:jira3_config]
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def load_wsdl_ops wsdl_file_name
    # Check if this object already exist in the cache.
    cache = Cache.instance
    if cache.has_in_cache?(wsdl_file_name)
      @wsdl_operations = cache.get(wsdl_file_name)
    else
      wsdl_doc = Util.get_public_uploaded_file wsdl_file_name
      parsed_wsdl = WSDLParser.parse wsdl_doc
      wsdl_util = WSDLUtil.new parsed_wsdl
      @wsdl_operations = wsdl_util.get_soap_input_operations true
      cache.add_to_cache(wsdl_file_name, @wsdl_operations)
    end

     @wsdl_id_op_map = convert_array_to_value_map @wsdl_operations
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def get_ticket_type type

    case type
      when /Jira3/
        @jira3_ticket_config = @ticket_config.ticket_client
        return 'Jira3x'
      when /Jira4/
        @jira4_ticket_config = @ticket_config.ticket_client
        return 'Jira4x'
      when /SOAP/
        soap_config = @ticket_config.ticket_client
        @input_map = soap_config.mappings
        # Important: de-serialized data is not converted to symbols, even if stored as such
        wsdl_file_name = @input_map['wsdl_file_name']
        load_wsdl_ops wsdl_file_name
        @selected_soap_op_id = @input_map['selected_soap_id'].chomp.to_i
        @operation = @wsdl_id_op_map.rassoc(@selected_soap_op_id)[0]
        session[:wsdl_file_name] = wsdl_file_name
        return 'SOAP supported'
      else
        return 'Nexpose'
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  #
  #-------------------------------------------------------------------------------------------------------------------
  def convert_array_to_value_map input
    map = {}

    index = 0
    input.each do |port_type, headers_and_ops|
      headers_and_ops['operations'].each do |key, value|
        op_name = port_type.to_s + "|" + key.to_s
        map[op_name] = index
        index += 1
      end
    end

    map
  end

end
