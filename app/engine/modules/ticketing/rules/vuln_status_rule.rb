require File.expand_path(File.join(File.dirname(__FILE__), 'rule'))

class VulnStatusRule < Rule

  def initialize accepts_ve, accepts_vv, accepts_vp
    @default = (accepts_ve and accepts_vp and accepts_vv)

    unless @default
      @accepts_ve = accepts_ve
      @accepts_vv = accepts_vv
      @accepts_vp = accepts_vp
    end
  end

  #
  #
  #
  def passes_rule? ticket_data
    # Don't process if default values are set.
    return true if @default

    vuln_status = ticket_data[:vuln_status].to_s.chomp
    if vuln_status.nil? or vuln_status.empty?
      return false
    end

    case vuln_status
      when /vulnerable-exploited/
        return @accepts_ve
      when /vulnerable-version/
        return @accepts_vv
      when /potential/
        return @accepts_vp
      else
        return false
    end
  end

end