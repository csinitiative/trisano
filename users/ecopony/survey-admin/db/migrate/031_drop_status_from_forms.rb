class DropStatusFromForms < ActiveRecord::Migration
  def self.up
    remove_column :forms, :status
  end

  def self.down
    add_column :forms, :status, :string
  end
end
