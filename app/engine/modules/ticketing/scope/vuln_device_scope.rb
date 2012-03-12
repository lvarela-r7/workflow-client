class VulnDeviceScope



  def self.build_ticket_data(site_device_listing, host_data_array, ticket_config)

  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns the ticket key for this scope type
  #---------------------------------------------------------------------------------------------------------------------
  def self.get_ticket_key(ticket)
    key = ''
    key << ticket[:device_id].to_s
    key << '|'
    key << ticket[:vuln_id].to_s
    key << '|'
    key << ticket[:port].to_s
    key << '|'
    key << ticket[:vkey].to_s
    key
  end
end