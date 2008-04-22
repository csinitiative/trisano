class AddConditionToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :condition, :string
  end

  def self.down
    remove_column :questions, :condition
  end
end
