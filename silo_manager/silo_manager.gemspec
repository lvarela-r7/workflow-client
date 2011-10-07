require 'rubygems'
require 'rake'

Gem::Specification.new do |spec|
	spec.name = 'silo_manager'
	spec.version = '0.0.2'
	spec.platform=Gem::Platform::RUBY
	spec.homepage='https://github.com/chrlee/silo_manager'
	spec.description=
<<Description
  This is a tool is used to provide CRUD silo operations.
Description
	spec.summary=
<<Summary
	This is a tool is used to provide CRUD silo operations.
Summary
	spec.add_dependency 'nexpose', '>= 0.0.4'
	spec.author = 'Christopher Lee'
	spec.email = 'christopher_lee@rapid7.com'
	spec.executables = ['silo_manager']
	spec.files = FileList['lib/*'].to_a
end
