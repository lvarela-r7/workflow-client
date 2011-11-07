class CreateTicketingStyles < ActiveRecord::Migration
  def self.up
    create_table :ticketing_styles do |t|
      t.string :name
      t.string :description
    end
  end

  def self.down
    drop_table :ticketing_styles
  end
end
