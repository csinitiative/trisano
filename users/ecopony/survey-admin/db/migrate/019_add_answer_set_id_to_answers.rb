class AddAnswerSetIdToAnswers < ActiveRecord::Migration
def self.up
    add_column :answers, :answer_set_id, :integer
  end

  def self.down
    remove_column :answers, :answer_set_id
  end
end
