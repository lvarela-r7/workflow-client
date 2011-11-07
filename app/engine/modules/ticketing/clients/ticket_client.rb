#---
# Abstraction for the rest of the ticket classes
# All ticket clients must extends this class
#---
class TicketClient

	@initialized = false
	def initialize
		formatter_dir = File.expand_path(File.join(File.dirname(__FILE__), '../formatters/'))
		Dir.open(formatter_dir).each { |file|
			if /formatter/ =~ file
				require formatter_dir + '/' + file
			end
		}
	end

	def get_formatter formatter_name
		# Load the default if none specified
		if formatter_name.nil? or formatter_name.to_s.empty?
			return DefaultFormatter.new
		end

		begin
			formatter = Object.const_get(formatter_name.to_s).new
		rescue Exception
			formatter = DefaultFormatter.new
		end
		formatter
	end

	def insert_ticket
		raise 'Ticket client abstraction called!'
	end

	def update_ticket
		raise 'Ticket client abstraction called!'
	end

	def delete_ticket
		raise 'Ticket client abstraction called!'
	end

	def create_test_ticket
		raise 'Ticket client abstraction called!'
	end

end