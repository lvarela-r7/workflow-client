# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
TicketClients.delete_all
TicketClients.create(:id => 1, :client => 'Jira3x', :client_connector => 'Jira3Client', :formatter => 'JiraFormatter')
TicketClients.create(:id => 2, :client => 'Jira4x', :client_connector => 'Jira4Client', :formatter => 'JiraFormatter')
TicketClients.create(:id => 3, :client => 'Nexpose', :client_connector => 'NexposeClient')
TicketClients.create(:id => 4, :client => 'Remedy', :client_connector => 'RemedyClient')

ScanHistoryTimeFrame.delete_all
ScanHistoryTimeFrame.create(:id=> 1, :time_type => 'Day(s)', :multiplicate => 86400)
ScanHistoryTimeFrame.create(:id=> 2, :time_type => 'Week(s)', :multiplicate => 604800)
ScanHistoryTimeFrame.create(:id=> 3, :time_type => 'Month(s)', :multiplicate => 2419200)
ScanHistoryTimeFrame.create(:id=> 4, :time_type => 'Year(s)', :multiplicate => 29030400)

TicketingStyles.delete_all
TicketingStyles.create(:id=>1, :name => 'Vulnerability per Device', :description => 'A ticket is created for each vulnerability found on a certain device')
TicketingStyles.create(:id=>1, :name => 'Vulnerability per Site', :description => 'A ticket is created for each unique vulnerability found on a certain site')
TicketingStyles.create(:id=>1, :name => 'Vulnerability per NSC', :description => 'A ticket is created for each unique vulnerability found anywhere')

ModuleType.delete_all
ModuleType.create(:id => 1, :view => 'ticket_configs', :title => "Ticketing", :description=>"Allows integration of NeXpose scan result data and supported ticketing tools.")

if GeneralConfiguration.all.empty?
  # Default of 1 week
  GeneralConfiguration.create(:scan_history_polling => 1, :scan_history_polling_time_frame => 2, :nsc_polling => 10)
end