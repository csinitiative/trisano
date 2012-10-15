class AddTrisanoAuthOldPasswordsToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.text    :old_passwords
    end
  end

  def self.down
    remove_column :users, :old_passwords
  end
end
