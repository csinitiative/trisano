class DisallowNullsInRequiredUserFields < ActiveRecord::Migration
  def self.up
    change_column :users, :uid,       :string, :null => false
    change_column :users, :user_name, :string, :null => false
    change_column :users, :status,    :string, :null => false
  end

  def self.down
    change_column :users, :uid,       :string, :null => true
    change_column :users, :user_name, :string, :null => true
    change_column :users, :status,    :string, :null => true
  end
end
