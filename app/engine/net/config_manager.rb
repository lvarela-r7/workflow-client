# Load the client connectors
client_dir = File.expand_path(File.join(File.dirname(__FILE__), '../clients/'))
Dir.open(client_dir).each { |file|
  if /client/ =~ file
    require client_dir + '/' + file
  end
}

# Load the formatters
formatter_dir = File.expand_path(File.join(File.dirname(__FILE__), '../formatters/'))
Dir.open(formatter_dir).each { |file|
  if /formatter/ =~ file
    require formatter_dir + '/' + file
  end
}

#------------------------------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------------------------------
class ConfigManager
  private_class_method :new

  @@instance = nil

	public
	#################
	# PUBLIC METHODS#
	#################

  #------------------------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------------------------
  def initialize
    NscConfig.find_all
    @config_hash = {}
    parse_config
    do_validation_and_load
  end

  #------------------------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------------------------
  def self.instance
    @@instance = new unless @@instance
    @@instance
  end

  #------------------------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------------------------
  def get_value key
  	@config_hash[key]
	end

  private

	#------------------------------------------------------------------------------------------------------
	#
	#------------------------------------------------------------------------------------------------------
	def parse_config
		begin
			config_file = File.new File.expand_path(File.join(File.dirname(__FILE__), '../config.ini')), 'r'
			line_number = 1
			while line = config_file.gets
				if line =~ /^\s*#/ or line !~ /=/
					next
				else
					line = line.chomp
					pieces = line.split(/=/)
					if pieces.length != 2
						raise Exception 'Invalid property set on line: #{line_number}'
					end
					@config_hash[pieces[0].chomp] = pieces[1].chomp
				end
				line_number = line_number + 1
			end
		ensure
			config_file.close
		end
	end

	#------------------------------------------------------------------------------------------------------
	# Used to validated the definitions needed to connect to
	# endpoints are valid
	# TODO: Implement
	#------------------------------------------------------------------------------------------------------
	def do_validation_and_load
		client_name = @config_hash['ticket_client']
		client_object = Object.const_get(client_name).new @config_hash['ticket_url']
		@config_hash['ticket_client'] = client_object

		formatter_name = @config_hash['ticket_formatter']
		formatter_object = Object.const_get(formatter_name).new
		@config_hash['ticket_formatter'] = formatter_object

		# Load the time deficit
		time_format = @config_hash['scan_history_polling']
		if time_format =~ /(\d+)([d|m|w|y])/
			count = $1.to_i
			format = $2.to_s.chomp
			case format
				when 'd'
							count = count * 86400
				when 'w'
							count = count * 7 * 86400
				when 'm'
							count = count * 4 * 7 * 86400
				when 'y'
							count = count * 12 * 4 * 7 * 86400
				else
					raise ArgumentError.new 'Illegal format specified'
			end
		else
			raise ArgumentError.new 'Illegal scan history poll time format'
		end

		@config_hash['scan_history_polling'] = count
	end

end