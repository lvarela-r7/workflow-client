require File.expand_path(File.join(File.dirname(__FILE__), 'formatter'))

class JiraFormatter < Formatter
  # To change this template use File | Settings | File Templates.

  def initialize
    @in_link_build = false
  end

  def do_ticket_description_format ticket_info
    # Build description section
    formatted_output = do_add_h3(do_underline 'Description')
    add_new_line formatted_output
    vuln_description_paragraph = build_paragraph ticket_info[:description]
    vuln_description_paragraph.get_paragraph.each do |output|
      do_formated_paragraph formatted_output, output
    end

    # Build description section
    formatted_output << do_add_h3(do_underline 'Proof')
    add_new_line formatted_output
    vuln_proof_paragraph = build_paragraph ticket_info[:proof]
    vuln_proof_paragraph.get_paragraph.each do |output|
      do_formated_paragraph formatted_output, output
    end

    # Build solution section
    add_new_line formatted_output
    formatted_output << do_add_h3(do_underline 'Solution')
    add_new_line formatted_output
    vuln_solution_paragraph = build_paragraph ticket_info[:solution]
    vuln_solution_paragraph.get_paragraph.each do |output|
      if @in_link_build and not output[:link]
        add_new_line formatted_output
      end

      do_formated_paragraph formatted_output, output
    end

    formatted_output
  end

  def do_formated_paragraph appended, output
    if output[:sentence]
      @in_link_build = false
      appended << output[:sentence]
      add_new_line appended
    else
      if output[:link]
        @in_link_build = true
        description = output[:link][0]
        link = make_link output[:link][1]
        line_item = '*'
        line_item << description
        line_item << '*'
        line_item << ': '
        line_item << link
        appended << (make_list_item line_item)
        add_new_line appended
      end
    end
  end

  def do_underline input
    output = '+'
    output << input.chomp
    output << '+'
    output
  end

  # All headings are on a new line
  def do_add_h3 input
    output = 'h3. '
    output << input
    output
  end

  def make_link input, description=nil
    output = '['
    if description
      output << "#{description}|"
    end
    output << input
    output << ']'
    output
  end

  def make_list_item item
    output = '- '
    output << item.chomp
    output
  end

  def make_array_list input_items
    output = ''
    input_items.each do |item|
      make_list_item item
    end

    output
  end

  def add_new_line input
    input << "\n"
  end
end