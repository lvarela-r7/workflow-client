#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Parses raw XML report from nexpose
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class RawXMLReportProcessor

  attr_accessor :host_data, :vuln_data

  #---------------------------------------------------------------------------------------------------------------------
  # Sets up the callback for the parser.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    @parser = Rex::Parser::NexposeXMLStreamParser.new
    @parser.callback = proc { |type, value|
      case type
        when :host
          @host_data << value
        when :vuln
          @vuln_data << value
      end
    }
  end

  #---------------------------------------------------------------------------------------------------------------------
  #  Parses the raw XML document.
  #---------------------------------------------------------------------------------------------------------------------
  def parse raw_xml
    @host_data = []
    @vuln_data = []

    REXML::Document.parse_stream(data.to_s, @parser)
  end
end