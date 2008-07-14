class AddShortnameToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :short_name, :string
  end

  def self.down
    remove_column :questions, :short_name
  end
end
