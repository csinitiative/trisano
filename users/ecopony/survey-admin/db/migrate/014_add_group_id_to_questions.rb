class AddGroupIdToQuestions < ActiveRecord::Migration
  def self.up
      add_column :questions, :group_id, :integer
  end

  def self.down
    remove_column :questions, :group_id
  end
end
