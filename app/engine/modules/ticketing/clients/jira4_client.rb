#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Determines if the user added mapping
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

class Jira4Client < TicketClient

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def initialize(*args)
    super()

    count = args.length
    if count == 1
      ticket_config = args[0]
      @ticket_client_config = ticket_config.ticket_client
      @ticket_mappings = ticket_config.ticket_mapping
      @mapping_defined = is_mapping_defined?

      uri = @ticket_client_config.host.to_s + ':' + @ticket_client_config.port.to_s
      @username = @ticket_client_config.username.to_s
      @password = @ticket_client_config.password.to_s
    elsif count == 4
      @username = args[0].to_s
      @password = args[1].to_s
      host = args[2].to_s
      port = args[3].to_s
      uri = host + ":" + port
    else
      raise "Invalid arg count for Jira4Client#initialize: #{count}"
    end

    unless uri =~ /^http/i
      uri = 'http://' + uri
    end
    @jira = JIRA::JIRAService.new uri
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def overlay_mappings data
    custom_field_values = []

    @ticket_mappings.attributes.each do |key, value|
      next unless value.kind_of? String
      next if value.empty?

      unless value =~ /customfield_/
        value = "customfield_#{value}"
      end

      # The key in this case is a string we need to convert to symbol
      key = key.to_sym if key.kind_of? String

      custom_field = JIRA::CustomFieldValue.new
      custom_field.id = value
      custom_field.values = [data[key]]
      custom_field_values << custom_field

      data.delete key
    end

    data[:custom_field_values] = custom_field_values
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def insert_ticket ticket_data
    msg = nil

    data = build_default_data_fields ticket_data

    if @mapping_defined
      data = overlay_mappings data
    end

    begin
      @jira.login @username, @password
      jira_issue = build_jira_issue data
      @jira.create_issue_with_issue jira_issue
      @jira.logout
    rescue Exception

      begin
        msg = $!.reason.chomp
      rescue Exception
        msg = "Could not contact JIRA"
      end

      if msg and msg.to_s.include? ':'
        msg = msg.split(':')[1]
      end

      if msg and msg[0] == '{'
        msg = msg[1..msg.length-3]
        if msg.include? '='
          msg = msg.split('=')[1]
        end
      end

      msg = msg ? msg.chomp : nil
    end
    msg
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def build_default_data_fields ticket_data
    data = {}

    # If this is a test ticket
    ticket_data if ticket_data[:ticket_type] and ticket_data[:ticket_type].eql?('test_ticket')

    ticket_data[:name] = (ticket_data[:name] || '')

    formatter = get_formatter ticket_data[:formatter].to_s
    vuln_id = ticket_data[:vuln_id]
    vuln_info = VulnInfo.find_by_vuln_id(vuln_id)
    raise "Could not find vuln data for vuln id: #{vuln_id}" unless vuln_info

    ticket_info = {
        :description => Util.process_db_input_array(vuln_info[:description]),
        :proof       => ticket_data[:proof],
        :solution    => Util.process_db_input_array(vuln_info[:solution])
    }

    description = formatter.do_ticket_description_format ticket_info
    summary     = "#{vuln_info[:title]} on #{ticket_data[:name]} (#{ticket_data[:ip]})"
    environment = ticket_data[:fingerprint].to_s

    data[:summary]           = summary.to_s
    data[:environment]       = environment
    data[:description]       = description.to_s
    data[:priority_id]       = @ticket_client_config.priority_id
    data[:project_name]      = @ticket_client_config.project_name
    data[:issue_type_id]     = @ticket_client_config.issue_id
    data[:reporter_username] = @ticket_client_config.reporter
    data[:assignee_username] = @ticket_client_config.assignee
    data[:cvss_score]        = vuln_info[:cvss]
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def is_mapping_defined?
    if @ticket_mappings
      @ticket_mappings.attributes.values.each do |value|
        next unless value.kind_of? String

        unless value.to_s.chomp.empty?
          return true
        end
      end
    end

    false
  end


  # It is confusing as to what the actual project name
  # is however JIRA expects something that ends with
  # "PROJECT"
=begin
		unless jira_issue.project_name =~ /project$/i
			jira_issue.project_name = jira_issue.project_name + 'project'
			# Case matters :p
			jira_issue.project_name.upcase!
		end
=end
  #
  # This should use the user defined map to build the jira issue
  #
  def build_jira_issue data

    jira_issue = JIRA::Issue.new

    data.each do |key, value|

      case key
        when :description
          jira_issue.description = value
        when :summary
          jira_issue.summary = value
        when :environment
          jira_issue.environment = value
        when :priority_id
          jira_issue.priority_id = value
        when :project_name
          jira_issue.project_name = value.to_s.upcase
        when :issue_type_id
          jira_issue.type_id = value
        when :reporter_username
          jira_issue.reporter_username = value
        when :assignee_username
          jira_issue.assignee_username = value
        when :custom_field_values
          JIRA::Issue.add_attribute :custom_field_values, 'customFieldValues', [:children_as_objects, JIRA::CustomFieldValue]
          jira_issue.custom_field_values = value
        else
          raise 'Unknown key when parsing jira fields.'
      end
    end

    jira_issue
  end

  def create_test_ticket form_input, ticket_mappings=nil

    if ticket_mappings
      @mapping_defined = true
      @ticket_mappings = ticket_mappings
    end

    data ={
        :summary => "test ticket",
        :priority_id => form_input[:priority_id],
        :assignee_username => form_input[:assignee],
        :reporter_username => form_input[:reporter],
        :environment => "test ticket",
        :description => "test ticket",
        :issue_type_id => form_input[:issue_id],
        :project_name => form_input[:project_name],
        :ticket_type => 'test_ticket',
        :cvss_score => '5.5'
    }
    insert_ticket data
  end

  #
  #
  #
  def update_ticket
    raise 'Ticket client abstraction called!'
  end

  #
  #
  #
  def delete_ticket

  end

end

=begin
begin
	jira4 = Jira4Client.new 'chrlee', 'badabing', 'localhost', '8080'

	data ={
	   :ticket_type => 'test_ticket',
	   :summary	    => "summary",
       :priority_id   	=> '1',
       :assignee_username  	=> 'chrlee',
       :reporter_username	  => 'chrlee',
       :environment	=> "unix",
       :description	=> "desc",
       :issue_type_id   => '1',
       :project_name => 'test'
	}

	msg = jira4.insert_ticket data
	puts msg

end
=end
