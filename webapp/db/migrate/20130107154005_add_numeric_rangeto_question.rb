class AddNumericRangetoQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :numeric_min, :string
    add_column :questions, :numeric_max, :string
  end

  def self.down
  end
end
