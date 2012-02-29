class TicketsToBeProcessed < ActiveRecord::Base
	serialize :ticket_data, Hash
end
