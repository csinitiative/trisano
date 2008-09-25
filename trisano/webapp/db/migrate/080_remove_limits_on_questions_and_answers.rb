class RemoveLimitsOnQuestionsAndAnswers < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE answers ALTER COLUMN text_answer TYPE varchar;")
    execute("ALTER TABLE questions ALTER COLUMN question_text TYPE varchar;")
    execute("ALTER TABLE questions ALTER COLUMN help_text TYPE varchar;")
  end

  def self.down
    execute("ALTER TABLE answers ALTER COLUMN text_answer TYPE varchar(255);")
    execute("ALTER TABLE questions ALTER COLUMN question_text TYPE varchar(255);")
    execute("ALTER TABLE questions ALTER COLUMN help_text TYPE varchar(255);")
  end
end
