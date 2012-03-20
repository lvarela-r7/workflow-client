class NexposeClient < TicketClient

  def initialize ticket_config
    begin
      @nexpose_client = ::Nexpose::Connection.new('127.0.0.1','v4test','buynexpose',3780)
      @nexpose_client.login
      @ticket_config = ticket_config
      nexpose_client_id = ticket_config[:ticket_client_id]
      nsc_config = NscConfig.find nexpose_client_id
      @ticket_config[:nexpose_default_user] = nsc_config[:username]
      @nexpose_client = NSCConnectionManager.instance.get_nsc_connection nsc_config.host
    rescue Exception
      @nexpose_client = nil
    end

    if @nexpose_client.nil?
      raise 'The Nexpose client could not be found'
    end
  end

  #
  # @param ticket_data: @see
  def create_ticket ticket_data

    nexpose_ticket_data = {}
    vuln_info = TicketManager.instance.vuln_map[ticket_data[:vuln_id]]

    nexpose_ticket_data[:vulnerabilities] = []
    nexpose_ticket_data[:vulnerabilities] << ticket_data[:vuln_id]

    nexpose_ticket_data[:assigned_to] = @ticket_config[:nexpose_default_user]
    nexpose_ticket_data[:priority] = 'normal'
    nexpose_ticket_data[:name] = vuln_info[:title]
    nexpose_ticket_data[:user] = @ticket_config[:nexpose_default_user]
    nexpose_ticket_data[:device_id] = ticket_data[:device_id]

    res = @nexpose_client.create_ticket nexpose_ticket_data
  end

  # There is no way to do update in NeXpose
  def update_ticket
    #
  end

  def delete_ticket ticket_data
    
  end

end

