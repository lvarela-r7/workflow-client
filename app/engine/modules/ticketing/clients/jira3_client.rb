class Jira3Client < TicketClient

  private
  def build_login_hash user_name, password
    {
        :os_username => user_name,
        :os_password => password,
        :os_destination => '/secure/'
    }
  end

  def is_success? response
    # JIRA 3 returns 302 and an empty body for a successfull post
    # The 'Location' header will contain the redirect to the URL
    # of the ticket for future reference
    response.status == 302 and response.content.to_s.chomp.empty?
  end

  public
  def initialize base_url
    @base_url = URI.parse base_url
    @http_client = HTTPClient.new
    @logged_in = false
  end

  # TODO: Handle expired sessions
  def login username, password
    res = @http_client.post @base_url, build_login_hash(username, password)
    puts res.inspect
    @logged_in = true
  end

  def post_data url, data
    unless @logged_in
      raise Exception 'Not logged in'
    end

    post_url = @base_url.merge url
    @http_client.post(post_url, data)
  end

  def update_ticket

  end

  def insert_ticket data
    #TODO: Needs to be re-written to build data from model data
=begin

							:priority => @ticket_priority,
					:assignee => @ticket_assignee,
					:reporter => @ticket_reporter,
					:environment => environment,
					:description => description.to_s,
					:pid => @ticket_pid,
					:issuetype => @ticket_issue_type_id,
=end
    data[:Create] = 'Create'
    create_ticket_url = '/secure/CreateIssueDetails.jspa'
    response = post_data create_ticket_url, data
    puts response.body
    is_success? response
  end

  def delete_ticket

  end
end

begin
=begin
	jirac = Jira3Client.new 'http://10.4.6.5:8080'
	jirac.login 'chrlee', 'badabing'

		data ={ :summary	    => "summary",
       :priority   	=> '1',
       :assignee  	=> 'chrlee',
       :reporter	  => 'chrlee',
       :environment	=> "unix",
       :description	=> "desc",
       :pid	        => '1000',
       :issuetype   => '1',
       :Create	    => 'Create'
		}

	jirac.insert_ticket data
=end
end