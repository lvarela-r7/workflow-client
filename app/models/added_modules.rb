class AddedModules < ActiveRecord::Base
	validates_presence_of :module_name, :message => 'The module name cannot be blank'
	validates_uniqueness_of :module_name, :message => 'That module name is already being used'
end
