class TicketConfig < ActiveRecord::Base

	validates_presence_of :module_name, :message => 'The module name cannot be blank'
	validates_uniqueness_of :module_name, :message => 'That module name is already being used'

	has_one :ticket_mapping, :foreign_key => "ticket_config_id", :dependent => :delete
	has_one :ticket_rule, :foreign_key => "ticket_config_id", :dependent => :delete
  has_one :ticket_scope, :foreign_key => "ticket_config_id", :dependent => :delete
	belongs_to :ticket_client, :polymorphic => true, :dependent => :destroy

	accepts_nested_attributes_for :ticket_mapping, :ticket_rule, :allow_destroy => true
end
