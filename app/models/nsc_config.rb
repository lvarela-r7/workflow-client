class NscConfig < ActiveRecord::Base

  # VALIDATIONS
  validates :host, :password, :port, :username, :presence => true
  validates :host, :uniqueness => true
end
