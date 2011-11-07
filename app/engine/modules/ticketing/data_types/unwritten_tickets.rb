class UnWrittenTickets

  def initialize
    @unwritten_tickets = {}
  end

  def add_unwritten_ticket key, data
    @unwritten_tickets[key] = data
  end

  def get_unwritten_tickets
    @unwritten_tickets
  end

end