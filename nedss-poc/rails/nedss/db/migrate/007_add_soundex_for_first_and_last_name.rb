class AddSoundexForFirstAndLastName < ActiveRecord::Migration
  def self.up
    add_column :people, :first_name_soundex, :string
    add_column :people, :last_name_soundex, :string
  end

  def self.down
    remove_column :people, :first_name_soundex
    remove_column:people, :last_name_soundex
  end
end
