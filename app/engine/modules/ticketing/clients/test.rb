require "nexpose"

class Test
  def self.client_name
    'name-arse'
  end
end

begin
=begin
	nexpose_client = Nexpose::Connection.new '10.2.77.241', 'v4test', 'buynexpose'
	nexpose_client.login
=end

  # ticket_info: A hash of the data to be used to create a ticket in NeXpose:
  # :name        => The name of the ticket (Required)
  # :device_id   => The NeXpose device ID for the device being ticketed (Required)
  # :assigned_to => The NeXpose user to whom this ticket is assigned (Required)
  # :priority    => "low,moderate,normal,high,critical" (Required)
  #
  # :vulnerabilities => An array of NeXpose vuln IDs  (Required)
  # :comments        => An array of comments to accompany this ticket

=begin
	vulns = ['adobe-reader-getplus-bof']
	comments = ['This is a test.']
	ticket_data = {
		:name => "Test Ticket",
		:device_id => "1",
		:assigned_to => "v4test",
		:priority => "critical",
		:vulnerabilities => vulns,
		:comments => comments
	}

	puts (nexpose_client.delete_ticket [18])
=end

  nsc_connection = Nexpose::Connection.new('localhost', 'v4test', 'buynexpose')
  nsc_connection.login
  adhoc_report_generator = Nexpose::ReportAdHoc.new nsc_connection
  adhoc_report_generator.addFilter 'scan', '6'
  data = adhoc_report_generator.generate
  puts data.to_s

end