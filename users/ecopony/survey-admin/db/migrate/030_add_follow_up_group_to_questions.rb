class AddFollowUpGroupToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :follow_up_group_id, :integer
  end

  def self.down
    remove_column :questions, :follow_up_group_id
  end
end
