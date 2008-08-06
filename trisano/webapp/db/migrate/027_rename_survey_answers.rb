class RenameSurveyAnswers < ActiveRecord::Migration

  def self.up
    rename_table :survey_answers, :answers
  end

  def self.down
    rename_table :answers, :survey_answers
  end

end
