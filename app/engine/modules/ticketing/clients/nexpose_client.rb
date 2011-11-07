require File.expand_path(File.join(File.dirname(__FILE__), 'ticket_client'))
require 'nexpose'

class NexposeClient < TicketClient

	def initialize nexpose_client
		@nexpose_client = nexpose_client
	end

	#
	# @param ticket_data: @see
	def insert_ticket ticket_data
		nexpose_ticket_data = {}

		#@nexpose_client.
	end

	# There is no way to do update in NeXpose
	def update_ticket
		#
	end

	def delete_ticket
		#
	end

end