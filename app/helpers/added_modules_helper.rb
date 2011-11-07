module AddedModulesHelper

	# Each new module will need to set its own path
	def module_specific_edit_path added_module
		case added_module.class.to_s
			when 'TicketConfig'
				edit_ticket_config_path(added_module)
		end
	end

end