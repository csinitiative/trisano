class AddQuestionIdToAnswerSets < ActiveRecord::Migration
  def self.up
    add_column :answer_sets, :question_id, :integer
  end

  def self.down
    remove_column :answer_sets, :question_id
  end
end
