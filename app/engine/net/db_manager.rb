

#------------------------------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------------------------------
class DBManager
  private_class_method :new

  @@instance = nil
  @@written_tickets_data_file = 'data_types/written_tickets.sav'
  @@unwritten_tickets_data_file = 'data_types/clients/unwritten_tickets.sav'
	@@last_site_scans_data_file = 'data_types/clients/last_site_scans.sav'

  def self.instance
    @@instance = new unless @@instance
    @@instance
  end

  def initialize
    if File.exist? @@written_tickets_data_file
      @written_tickets = Marshal.load(File.open @@written_tickets_data_file)
    else
      @written_tickets = WrittenTickets.new
    end

    if File.exist? @@unwritten_tickets_data_file
      @un_written_tickets = Marshal.load(File.open @@unwritten_tickets_data_file)
    else
      @un_written_tickets = UnWrittenTickets.new
		end

		if File.exist? @@last_site_scans_data_file
      @last_site_scan = Marshal.load(File.open @@last_site_scans_data_file)
    else
      @last_site_scan = LastSiteScan.new
    end

  end

  def has_written_ticket? key
    @written_tickets.isWritten? key
  end

  def add_written_ticket key
    @written_tickets.add_key key
    File.open( @@written_tickets_data_file, 'w' ){ |f| Marshal.dump( @written_tickets, f )}
  end

  def add_unwritten_ticket key, data
    @un_written_tickets.add_unwritten_ticket key, data
    File.open( @@unwritten_tickets_data_file, 'w' ){ |f| Marshal.dump( @unwritten_tickets, f )}
  end

  def get_unwritten_tickets
    @un_written_tickets.get_unwritten_tickets
  end

	def add_last_site_scan site_id, scan_id
		@last_site_scan.add_last_site_scan site_id, scan_id
		File.open( @@last_site_scans_data_file, 'w' ){ |f| Marshal.dump( @last_site_scan, f )}
	end

	def get_last_scan_id site_id
		@last_site_scan.get_last_scan_id site_id
	end
end

begin
	h = {}
	test  = {}
	test['l'] = 'bebes'
	h[:a] = 'weda'
	h[:t] = test

	puts h.to_s

	a = eval h.to_s
	puts a[:t]['l']
end