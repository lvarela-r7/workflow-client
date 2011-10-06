require 'ostruct'
require 'optparse'

#------------------------------------------------------------------------------------------------------
# Defines options to be executed against the NeXpose API
#------------------------------------------------------------------------------------------------------
class Options
	def self.parse(args)
		options = OpenStruct.new
		options.port = 3780
		options.host = 'localhost'


		option_parser = OptionParser.new do |option_parser|
			option_parser.on("-h host", "The network address of the NeXpose instance - Defaults to 'localhost'") { |arg| options.host=arg.chomp }
			option_parser.on("-u user_name", "The NeXpose user name - Required") { |arg| options.user=arg.chomp }
			option_parser.on("-p password", "The NeXpose password - Required") { |arg| options.password=arg.chomp }
			option_parser.on("--port port", "The NSC port - Defaults to 3780") { |arg| options.port=arg.chomp }
			option_parser.on_tail("--help", "Help") do
				puts option_parser
				exit 0
			end
		end

		begin
			option_parser.parse!(args)
		rescue OptionParser::ParseError => e
			puts "#{e}\n\n#{option_parser}"
			exit 1
		end

		options
	end
end