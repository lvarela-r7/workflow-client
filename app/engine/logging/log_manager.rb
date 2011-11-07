class LogManager

	private_class_method :new

	@@instance = nil

	def initialize
		@nsc_connections = {}
		@log_lines = []
	end

	def self.instance
   		@@instance = new unless @@instance
    	@@instance
	end

	def add_log_message message
		formatter = message[0..2]
		core_message = message[3..message.length-1]
		log_message = formatter
		log_message << get_time_block
		log_message << core_message
		@log_lines << log_message
	end

	# line starts at 1, so index is always line-1
	# TODO: If current_line is greater than log length,
	# refresh the page.
	def get_messages_since_line current_line
		message_start_index = current_line - 1
		if message_start_index >= @log_lines.length-1
			[]
		else
			@log_lines[current_line..@log_lines.length-1]
		end
	end

	def get_log_body
		@log_lines
	end

	def get_time_block
		time_block = '['
		time_block << Time.now.to_s
		time_block << ']'
		time_block
	end

end