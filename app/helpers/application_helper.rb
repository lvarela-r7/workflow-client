module ApplicationHelper
	def class_for_tab(tab)
		(controller_name == tab.to_s) ? "sel #{tab}" : tab.to_s
	end
end

