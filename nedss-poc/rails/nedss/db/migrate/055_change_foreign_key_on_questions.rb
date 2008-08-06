class ChangeForeignKeyOnQuestions < ActiveRecord::Migration
  def self.up
    rename_column :questions, :question_element_id, :form_element_id
  end

  def self.down
    rename_column :questions, :form_element_id, :question_element_id
  end
end
