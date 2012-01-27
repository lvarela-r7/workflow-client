class IntegerPropertyValidator < ActiveModel::Validator
  def validate record
    input_value = record.property_value
    unless input_value =~ /^\d+$/
      record.errors[:base] << "Input for #{record.property_key} should be an integer"
    end
  end
end

class IntegerProperty < ActiveRecord::Base
  validates_with IntegerPropertyValidator
end
