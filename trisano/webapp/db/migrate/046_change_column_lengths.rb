class ChangeColumnLengths < ActiveRecord::Migration
  def self.up
    change_column(:privileges, :priv_name, :string, :limit => 50)
    change_column(:users, :uid, :string, :limit => 50)
  end

  def self.down
    change_column(:privileges, :priv_name, :string, :limit => 15)
    change_column(:users, :uid, :string, :limit => 9)
  end
end
