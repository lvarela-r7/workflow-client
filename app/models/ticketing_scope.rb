class TicketingScope < ActiveRecord::Base

  belongs_to :ticket_config, :foreign_key => "ticket_config_id"
end
