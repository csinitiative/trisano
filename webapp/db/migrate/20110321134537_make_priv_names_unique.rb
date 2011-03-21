class MakePrivNamesUnique < ActiveRecord::Migration
  def self.up
    add_index :privileges, :priv_name, :unique => true
  end

  def self.down
    remove_index :privileges, :priv_name
  end
end
