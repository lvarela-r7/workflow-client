#TODO:  Rearch - This is wrong
class IntegerRangeRule < Rule

  # Implementing classes should set this.
  @MAX_SCORE = 0
  @MIN_SCORE = 0

  #
  #
  #
  def initialize min, max
    @default = (@MAX_SCORE == max and @MIN_SCORE == min)

    unless @default
      @min = min.to_f
      @max = max.to_f
    end
  end

  #
  #
  #
  def passes_rule? ticket_data
    # Don't process if default values are set.
    return true #if @default

    cvss_score = ticket_data[:cvss]
    if cvss_score.nil? or cvss_score.to_s.chomp.empty?
      raise "CVSS score was null for ticket data passed: #{ticket_data.inspect}"
    end

    cvss_score = cvss_score.to_s.to_f
    (cvss_score >= @min and cvss_score <= @max)
  end
end
