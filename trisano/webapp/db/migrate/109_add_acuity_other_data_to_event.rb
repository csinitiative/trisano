class AddAcuityOtherDataToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :acuity, :string
    add_column :events, :other_data_1, :string
    add_column :events, :other_data_2, :string
  end

  def self.down
    remove_column :events, :other_data_2
    remove_column :events, :other_data_1
    remove_column :events, :acuity
  end
end
