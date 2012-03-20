#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Represents the base ticket format: one ticket is created for a device and vulnerability combo.
# ie: devices: 1 and 2
#     vulns:  a and b
# Creates 4 tickets: 1a, 1b, 2a, 2b
#
# This scope only supports 2 formats: OPEN and CLOSED, as UPDATES to this kind
# of ticket is illogical.
#
# TODO: For now we ignore the process queue
# TODO: Add logic to support out of order scan processing
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class VulnDeviceScope


  def self.build_ticket_data(nexpose_host, site_device_listing, host_data_array, ticket_config)
    res = []

    # Only do update process if the module supports it
    supports_updates = ticket_config.supports_updates

    # A map of the device_id + vuln_id => tickets_created
    non_vulns = {}
    vuln_tickets = []

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
        query_key = module_name + nexpose_host + device_id + vuln_id

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
              :nexpose_host => nexpose_host,
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
              :ticket_op => :CREATE,
              :module_name => module_name
          }

          ticket_id = self.get_ticket_key(ticket_data)
          ticket_data[:ticket_id] = ticket_id

          # Add to array used to filter out still vulnerable tickets
          vuln_tickets << {:ticket_id => ticket_id, :query_key => query_key}

          unless self.ticket_created_or_to_be_processed?(ticket_data)
            if rule_manager.passes_rules?(ticket_data)
              res << ticket_data
            end
          end

        # Process Non-vulnerable items
        else
          if supports_updates
            query = "SELECT * FROM tickets_createds where ticket_id LIKE '%#{query_key}%'"
            tickets_created = TicketsCreated.find_by_sql(query)
            if tickets_created
              non_vulns[query_key] = tickets_created
            end
          end
        end
      }

      if supports_updates and not non_vulns.empty?
         # Process the non_vulns
         # 1. For all tickets that are still vulnerable find them in the map
         # 2. Remove those tickets that match the ticket_id
         vuln_tickets.each do |vuln_ticket|
            process_list = non_vulns[vuln_ticket[:query_key]]
            if process_list
              process_list.each do |ticket|
                if ticket.ticket_id.eql?(vuln_ticket[:ticket_id])
                  process_list.delete(ticket)
                  # There can only be one.
                  break
                end
              end
            end
         end

         # If there is any data left, normalize and make tickets
         non_vulns.keys.each do |key|
           process_list = non_vulns[key]
           process_list.each do |ticket_created|
             ticket_data = {
                           :ticket_data => ticket_created,
                           :nexpose_host => nexpose_host,
                           :formatter => formatter,
                           :client_connector => client_connector,
                           :ticket_op => :DELETE,
                           :module_name => module_name
                       }
             res << ticket_data
           end
         end
      end
    end

    res
  rescue Exception => e
    LogManager.instance.add_log_message "[!] Error in Building Ticket Data: #{e.backtrace}"
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns the ticket key for this scope type
  #---------------------------------------------------------------------------------------------------------------------
  def self.get_ticket_key(ticket)
    key = ''
    key << ticket[:module_name]
    key << '|'
    key << ticket[:nexpose_host]
    key << '|'
    key << ticket[:device_id].to_s
    key << '|'
    key << ticket[:vuln_id].to_s
    key << '|'
    key << ticket[:port].to_s
    key << '|'
    key << ticket[:vkey].to_s
    key
  end

  #---------------------------------------------------------------------------------------------------------------------
  # @retuns true iff the ticket has already been created or is being processed
  #---------------------------------------------------------------------------------------------------------------------
  def self.ticket_created_or_to_be_processed?(ticket_data)
    ticket_id = ticket_data[:ticket_id]
    return (TicketsCreated.where(:ticket_id => ticket_id).exists? or TicketsToBeProcessed.where(:ticket_id => ticket_id).exists?)
  end

end