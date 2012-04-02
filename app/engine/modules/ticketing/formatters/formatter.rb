require File.expand_path(File.join(File.dirname(__FILE__), 'paragraph'))

#------------------------------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------------------------------
class Formatter

  # Both parameters are array input from the parser of either string or hash which contains the link
  # ticket_info: Contains :description, :solution, and :proof
  def do_ticket_description_format ticket_info
    raise 'Formatter abstracion called!'
  end

  #------------------------------------------------------------------------------------------------------
  # input: An input array
  #------------------------------------------------------------------------------------------------------
  def build_paragraph input

    paragraph = Paragraph.new

    input.split("||").each do |line|
      if line.kind_of? Hash
        line.each { |key, value| paragraph.add_link key, value }
      elsif line.kind_of? Array
        line.each { |l| paragraph.add_sentence l }
      else
        line.gsub!(/[\r\n\t]/, '\r' => '', '\n' => '', '\t' => '')
        if line.empty?
          next
        else
          paragraph.add_sentence line
        end
      end
    end

    paragraph
  end

end
