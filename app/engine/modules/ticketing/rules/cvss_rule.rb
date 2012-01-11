require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class CVSSRule < Rule

  @MAX_CVSS_SCORE = 10
  @MIN_CVSS_SCORE = 1

  #
  #
  #
  def initialize min, max
    @default = (@MAX_CVSS_SORE == max and @MIN_CVSS_SCORE == min)

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
    return true if @default

    cvss_score = ticket_data[:cvss]
    if cvss_score.nil? or cvss_score.to_s.chomp.empty?
      raise "CVSS score was null for ticket data passed: #{ticket_data.inspect}"
    end

    cvss_score = cvss_score.to_s.to_f
    (cvss_score >= @min and cvss_score <= @max)
  end

end