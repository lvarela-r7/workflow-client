class DeviceScope

  def self.build_ticket_data(site_device_listing, host_data_array, ticket_config)

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