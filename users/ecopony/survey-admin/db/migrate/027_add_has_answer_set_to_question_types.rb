class AddHasAnswerSetToQuestionTypes < ActiveRecord::Migration
  def self.up
    add_column :question_types, :has_answer_set, :boolean
  end

  def self.down
    remove_column :question_types, :has_answer_set
  end
end
