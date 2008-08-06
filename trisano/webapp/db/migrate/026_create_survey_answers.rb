class CreateSurveyAnswers < ActiveRecord::Migration

  def self.up
    create_table :survey_answers do |t|
      t.integer :event_id
      t.integer :question_id
      t.string  :text_answer, :limit => 255
    end
  end

  def self.down
    drop_table :survey_answers
  end

end
