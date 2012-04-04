class VulnScope

  def self.build_ticket_data(nexpose_host, site_device_listing, host_data_array, ticket_config)
    vulns = {}

    supports_updates = ticket_config.supports_updates
    rule_manager = RuleManager.new(ticket_config.ticket_rule)
    c = Object.const_get(ticket_config.ticket_client_type)
    ticket_client_info = TicketClients.find_by_client(c.client_name)
    client_connector = ticket_client_info.client_connector
    formatter = ticket_client_info.formatter

    host_data_array.each do |host_data|

      host_ticket_data = {}

      device_id = self.get_device_id(host_data['addr'], site_device_listing)
      name = ''
      name = host_data['names'][0] if (!host_data['names'][0].nil? && !host_data['names'][0].empty?)
      fingerprint = ''
      fingerprint << (host_data['os_vendor'] || '')
      fingerprint << (host_data['os_family'] || '')

      host_ticket_data[:device_id] = device_id
      host_ticket_data[:name] = name
      host_ticket_data[:fingerprint] = fingerprint
      host_ticket_data[:ip] = host_data['addr']

      host_data["vulns"].each do |vuln|
   
        id = vuln[0]

        vulns[id]                    ||= {}
        vulns[id][:ticket_id]        ||= vuln[0]
        vulns[id][:ticket_op]        ||= :CREATE
        vulns[id][:hosts]            ||= [] #create hosts array for parent hash if it doesn't exist already
        vulns[id][:hosts]            << host_ticket_data
        vulns[id][:client_connector] ||= client_connector
        vulns[id][:formatter]        ||= formatter
      end

      #TODO
      #We won't perform rule-checks on the Ticket Per Vulnerability scope
      #This is because our current rules are based on a host-based ticket
      #If you blacklist 192.168.1.123, it is found vulnerable with ms08-067
      #and so is the rest of the /24, the whole ticket wouldn't show up
      #
      #We should create RuleTypes and use only rules that pertain to vulnerabilities
      #instead of using host based rules.
      #
      #rule exempt for now

    end
    vulns.to_a.flatten
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns the ticket key for this scope type
  #---------------------------------------------------------------------------------------------------------------------
  def get_ticket_key(ticket)
    key = ''
    key << ticket[:vuln_id].to_s
    key
  end

  def self.ticket_created_or_to_be_processed(ticket_data)
    ticket_id = ticket_data[:ticket_id]
    return (TicketsCreated.where(:ticket_id => ticket_id).exists? or TicketsToBeProcessed.where(:ticket_id => ticket_id).exists?)
  end

  def self.get_device_id(ip, site_device_listing)
    raise ArgumentError.new('Site device listing is null') unless site_device_listing

    site_device_listing.each do |device_info|
      return device_info[:device_id] if device_info[:address] =~ /#{ip}/
    end
  end
end
