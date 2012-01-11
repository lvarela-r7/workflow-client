#-------------------------------------------------------------------------------------------------------------------
# Singleton class that manages logging to the log screen.
#
# @author: Christopher Lee, christopher_lee@rapid7.com
#-------------------------------------------------------------------------------------------------------------------
class LogManager

  private_class_method :new

  @@instance = nil

  #-------------------------------------------------------------------------------------------------------------------
  # Initializes the log manager
  #-------------------------------------------------------------------------------------------------------------------
  def initialize
    @log_lines = []
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Singleton initialization
  #-------------------------------------------------------------------------------------------------------------------
  def self.instance
    @@instance = new unless @@instance
    @@instance
  end


  #-------------------------------------------------------------------------------------------------------------------
  # Adds a log message
  #
  # @param message The log message to add.
  #-------------------------------------------------------------------------------------------------------------------
  def add_log_message message
    formatter = message[0..2]
    core_message = message[3..message.length-1]
    log_message = formatter
    log_message << get_time_block
    log_message << core_message
    @log_lines << log_message
  end

  #-------------------------------------------------------------------------------------------------------------------
  # line starts at 1, so index is always line-1
  # TODO: If current_line is greater than log length refresh the page.
  #-------------------------------------------------------------------------------------------------------------------
  def get_messages_since_line current_line
    message_start_index = current_line - 1
    if message_start_index >= @log_lines.length-1
      []
    else
      @log_lines[current_line..@log_lines.length-1]
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Returns the full log
  #-------------------------------------------------------------------------------------------------------------------
  def get_log_body
    @log_lines
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Returns the current time
  #-------------------------------------------------------------------------------------------------------------------
  def get_time_block
    time_block = '['
    time_block << Time.now.to_s
    time_block << ']'
    time_block
  end

end