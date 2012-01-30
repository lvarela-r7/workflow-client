class IntegerProperty < ActiveRecord::Base
  validates_numericality_of :property_value, :only_integer => true
end
