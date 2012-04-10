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
    p "Initializing JIRA4 client..."
    count = args.length
    if count == 1
      ticket = args[0]
      #
      @ticket_client_config = ticket[:ticket_config]
      @ticket_mappings = ticket[:ticket_mapping] if ticket[:ticket_mapping]
      @mapping_defined = is_mapping_defined? if @ticket_mappings

      begin
        @client_info = Jira4TicketConfig.find(@ticket_client_config.ivars["attributes"]["ticket_client_id"])
      rescue
        @client_info = Jira4TicketConfig.find(@ticket_client_config.ticket_client_id)
      end

      uri = @client_info.host.to_s + ':' + @client_info.port.to_s
      @username = @client_info.username.to_s
      @password = @client_info.password.to_s
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

    data ||= {}
    data[:custom_field_values] = custom_field_values
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def create_ticket ticket_data
    data = build_default_data_fields ticket_data
    if @mapping_defined
      data = overlay_mappings data
    end

    begin
      @jira.login @username, @password
      jira_issue = build_jira_issue data
      @jira.create_issue_with_issue jira_issue
      @jira.logout
    rescue Exception => e
      p e.message
      p e.backtrace
      return false
    end
    return true
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Determines if the user added mapping
  #---------------------------------------------------------------------------------------------------------------------
  def build_default_data_fields ticket_data
    data = {}

    # If this is a test ticket
    if ticket_data[:ticket_type] and ticket_data[:ticket_type].eql?('test_ticket')
      # Remove unknown to JIRA map attribute
      ticket_data.delete(:ticket_type)
      return ticket_data
    end


    ticket_data[:name] ||=  ''

    formatter = get_formatter ticket_data[:formatter].to_s
    vuln_id = ticket_data[:vuln_id]
    
    if vuln_id and not vuln_id.empty?
      vuln_info = VulnInfo.find_by_vuln_id(vuln_id)
      raise "Could not find vuln data for vuln id: #{vuln_id}" unless vuln_info
      
      ticket_info = {
          :description => vuln_info.vuln_data[:description],
          :proof       => ticket_data[:proof],
          :solution    => vuln_info.vuln_data[:solution]
      }

      description = formatter.do_ticket_description_format ticket_info
      #description = ticket_info[:description] + ticket_info[:solution]
      summary     = "#{vuln_info.vuln_data[:title]} on #{ticket_data[:ip]}"

      summary << " (#{ticket_data[:name]})" if ticket_data[:name] and !ticket_data[:name].empty?

      environment = ticket_data[:fingerprint].to_s

      #JIRA summaries will fail if greater than 255 characters long
      if summary.length < 255
        data[:summary] = summary.to_s
      else
        data[:summary] = summary[0,254]
      end

      data[:environment]       = environment
      data[:description]       = description
      data[:priority_id]       = @client_info.priority_id
      data[:project_name]      = @client_info.project_name
      data[:issue_type_id]     = @client_info.issue_id
      data[:reporter_username] = @client_info.reporter
      data[:assignee_username] = @client_info.assignee
      data[:cvss_score]        = vuln_info[:cvss]
      data
    elsif ticket_data[:host_vulns]
      data = {}

      data[:summary] = ticket_data[:ip] 
      data[:summary] << (ticket_data[:name] ? "("+ticket_data[:name]+")" : '')
      data[:summary] << " has " + ticket_data[:host_vulns].length.to_s + " vulnerabilities"
      data[:environment] = ticket_data[:fingerprint]
      data[:priority_id] = @client_info.priority_id
      data[:project_name] = @client_info.project_name
      data[:issue_type_id] = @client_info.issue_id
      data[:reporter_username] = @client_info.reporter
      data[:assignee_username] = @client_info.assignee

      data[:description] = ''
      ticket_data[:host_vulns].each do |vuln|
        vuln_info = VulnInfo.find_by_vuln_id(vuln[0])
        data[:description] << vuln_info.vuln_data[:description]
      end
      data
    elsif ticket_data[:hosts] #PerVuln scope
      data = {}

      vuln_info = VulnInfo.find_by_vuln_id(ticket_data[:ticket_id])
      data[:description] = vuln_info.vuln_data[:description]

      data[:summary] = ticket_data[:hosts].length.to_s + " hosts are vulnerable to "
      data[:summary] << ticket_data[:ticket_id]
      data[:priority_id] = @client_info.priority_id
      data[:project_name] = @client_info.project_name
      data[:issue_type_id] = @client_info.issue_id
      data[:reporter_username] = @client_info.reporter
      data[:assignee_username] = @client_info.assignee

      #data[:description] = ''
      ticket_data[:hosts].each do |host|
        data[:description] << "|" + host[:ip]
      end
      data
    else
      #test ticket for now...
      if @client_info
        data = {}
        data[:summary] = "Test ticket"
        data[:environment] = "N/A"
        data[:priority_id] = @client_info.priority_id
        data[:project_name] = @client_info.project_name
        data[:issue_type_id] = @client_info.issue_id
        data[:reporter_username] = @client_info.reporter
        data[:assignee_username] = @client_info.assignee
      else

      end
    end
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

    p "Building JIRA issue..."

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
        when :cvss_score
          #do nothing
        when :custom_field_values
          JIRA::Issue.add_attribute :custom_field_values, 'customFieldValues', [:children_as_objects, JIRA::CustomFieldValue]
          jira_issue.custom_field_values = value
        else
          raise "Unknown key #{key} when parsing jira fields."
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
        :ticket_type => 'test_ticket'
    }
    create_ticket data
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
