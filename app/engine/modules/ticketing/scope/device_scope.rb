class DeviceScope

  def self.build_ticket_data(site_device_listing, host_data_array, ticket_config)
    res = []

    # A map of the device_id + vuln_id => tickets_created
    non_vulns = {}

    # Load rule manager for each config
    rule_manager = RuleManager.new(ticket_config.ticket_rule)

    # Need to set the client_connector as part of the data returned
    c = Object.const_get(ticket_config.ticket_client_type.to_s)
    ticket_client_info = TicketClients.find_by_client(c.client_name)
    client_connector = ticket_client_info.client_connector.to_s

    # Need to set the formatter too
    formatter = ticket_client_info.formatter

    host_data_array.each do |host_data|
      ip = host_data['addr']
      names = host_data['names']
      device_id = get_device_id(ip, site_device_listing)

      # Just take the first name
      # TODO: Think about this more
      name = ''
      name = names[0] if !names.nil? || !names.empty?

      fingerprint = ''
      fingerprint << (host_data['os_vendor'] || '')
      fingerprint << ' '
      fingerprint << (host_data['os_family'] || '')

      host_data['vulns'].each { |vuln_id, vuln_info|
        vuln_status = vuln_info['status']

        if Util.is_vulnerable?(vuln_status)
          vkey = (vuln_info['key'] || '')
          vuln_endpoint_data = vuln_info['endpoint_data']

          port = ''
          protocol = ''
          if vuln_endpoint_data
            port = (vuln_endpoint_data['port'] || '')
            protocol = (vuln_endpoint_data['protocol'] || '')
          end

          # Format to avoid weird DB issues
          proof = Util.process_db_input_array(vuln_info['proof'], true)

          ticket_data = {
              :ip => ip,
              :device_id => device_id,
              :name => name,
              :fingerprint => fingerprint,
              :vuln_id => vuln_id,
              :vuln_status => vuln_status,
              :port => port,
              :protocol => protocol,
              :vkey => vkey,
              :proof => proof,
              :formatter => formatter,
              :client_connector => client_connector,
              :module => module_name
          }

          if rule_manager.passes_rules?(ticket_data)
            res << ticket_data
          end

        # Process Non-vulnerable items
        else
          ticket_match = device_id + vuln_id
          TicketsCreated.
        end
      }
    end

    res
  rescue Exception => e
    @logger.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns the ticket key for this scope type
  #---------------------------------------------------------------------------------------------------------------------
  def get_ticket_key(ticket)
    key = ''
    key << ticket[:device_id].to_s
    key
  end
end