# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

IntegerProperty.create(:property_key => 'scan_history_polling', :property_value => 1)
IntegerProperty.create(:property_key => 'scan_history_polling_time_frame', :property_value => 2)
IntegerProperty.create(:property_key => 'nsc_polling', :property_value => 20)
IntegerProperty.create(:property_key => 'scan_history_poll_period', :property_value => 200)
IntegerProperty.create(:property_key => 'max_ticketing_attempts', :property_value => 3)

TicketClients.delete_all
TicketClients.create(:id => 2, :client => 'Jira4x', :client_connector => 'Jira4Client', :formatter => 'JiraFormatter')
TicketClients.create(:id => 4, :client => 'SOAP supported', :client_connector => 'GenericSoapClient')

ScanHistoryTimeFrame.delete_all
ScanHistoryTimeFrame.create(:id=> 1, :time_type => 'Day(s)', :multiplicate => 86400)
ScanHistoryTimeFrame.create(:id=> 2, :time_type => 'Week(s)', :multiplicate => 604800)
ScanHistoryTimeFrame.create(:id=> 3, :time_type => 'Month(s)', :multiplicate => 2419200)
ScanHistoryTimeFrame.create(:id=> 4, :time_type => 'Year(s)', :multiplicate => 29030400)

TicketingScope.delete_all
TicketingScope.create(:id=>1, :name => 'Ticket per Vulnerability per Device', :description => 'A ticket is created for each vulnerability found on a certain device')
TicketingScope.create(:id=>2, :name => 'Ticket per Device', :description => 'All vulnerabilities for a site scan are aggregated per device')
TicketingScope.create(:id=>3, :name => 'Ticket per Vulnerability per NSC', :description => 'A ticket is created for each unique vulnerability found anywhere')

ModuleType.delete_all
ModuleType.create(:id => 1, :view => 'ticket_configs', :title => "Ticketing", :description=>"Allows integration of Nexpose scan result data and supported ticketing tools.")

