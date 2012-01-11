#-----------------------------------------------------------------------------------------------------------------------
# Abstraction for the rest of the ticket classes
# All ticket clients must extends this class
#
# @author: Christopher Lee, christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class TicketClient

  @initialized = false

  #-------------------------------------------------------------------------------------------------------------------
  # Initialized the ticket client with the default formatters.
  #-------------------------------------------------------------------------------------------------------------------
  def initialize
    formatter_dir = File.expand_path(File.join(File.dirname(__FILE__), '../formatters/'))
    Dir.open(formatter_dir).each { |file|
      if /formatter/ =~ file
        require formatter_dir + '/' + file
      end
    }
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Loads the ticket formatter for a ticket client if one is defined, else load the default formatter.
  #-------------------------------------------------------------------------------------------------------------------
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

  #-------------------------------------------------------------------------------------------------------------------
  # Unsupported op.
  #-------------------------------------------------------------------------------------------------------------------
  def insert_ticket
    raise 'Ticket client abstraction called!'
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Unsupported op.
  #-------------------------------------------------------------------------------------------------------------------
  def update_ticket
    raise 'Ticket client abstraction called!'
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Unsupported op.
  #-------------------------------------------------------------------------------------------------------------------
  def delete_ticket
    raise 'Ticket client abstraction called!'
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Unsupported op.
  #-------------------------------------------------------------------------------------------------------------------
  def create_test_ticket
    raise 'Ticket client abstraction called!'
  end

end