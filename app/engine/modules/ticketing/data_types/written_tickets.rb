class WrittenTickets

  def initialize
    @written_tickets = []
  end

  def isWritten? key
    (@written_tickets.count key.to_s.chomp).to_i > 0
  end

  # key: A string of dev-id|port|vid|vkey
  def add_key key
    @written_tickets << key
  end

end