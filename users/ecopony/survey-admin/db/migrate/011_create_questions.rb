class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :text
      t.string :help
      t.integer :question_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
