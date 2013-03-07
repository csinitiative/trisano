class ChangeUnitNumberColumnLength < ActiveRecord::Migration
  def self.up
    change_column(:addresses, :unit_number, :string, :limit => 60)
  end

  def self.down
    change_column(:addresses, :unit_number, :string, :limit => 10)
  end
end
