class TicketsToBeCreated < ActiveRecord::Base
	serialize :ticket_data, Hash
end
