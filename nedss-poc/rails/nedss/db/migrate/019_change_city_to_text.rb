class ChangeCityToText < ActiveRecord::Migration
  def self.up
    remove_column :addresses, :city_id
    add_column :addresses, :city, :string
  end

  def self.down
    remove_column :addresses, :city
    add_column :addresses, :city_id, :integer
  end
end
