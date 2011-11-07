class AddedModulesController < ApplicationController

	respond_to :html

	# Here is where you add additional module data
	# All module models should implement the same 4 methods:
	# 1. module name
	# 2. is active
	# 3. edit path
	# 4. delete path
	def index
		@added_modules = []

		# 1. Ticket Modules
		ticket_configs = TicketConfig.all
		if ticket_configs and ticket_configs.length > 0
			@added_modules.concat ticket_configs
		end

	end

	#
	#
	#
	def destroy
		modules_to_remove = params[:added_module_ids]
		if modules_to_remove and modules_to_remove.length > 0
			modules_to_remove.each do |dom_id|
				parsed_string = parse_key_and_id dom_id
				if parsed_string[0].to_s.chomp.eql?('ticketconfig')
					id = parsed_string[1].to_i
					TicketConfig.find(id).destroy
				end
			end
		end

		respond_with{|format|format.html{ redirect_to '/added_modules' }}
	end

	private

	def parse_key_and_id dom_id
		parsed_string = dom_id.split '_'
		# if size == 2 perfect
		if parsed_string.length == 2
			parsed_string
		elsif parsed_string.length > 2
			returned_array = []
			mashed_string_length = parsed_string.length - 2
			mashed_string = ''
			(0..mashed_string_length).each do |i|
				mashed_string.concat parsed_string[i]
			end
			returned_array << mashed_string
			returned_array << parsed_string[parsed_string.length-1]
			returned_array
		else
			raise 'The DOM ID is invalid'
		end

	end
end