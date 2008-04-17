class AddHtmlFormTypeToQuestionType < ActiveRecord::Migration
  def self.up
     add_column :question_types, :html_form_type, :string
  end

  def self.down
    remove_column :question_types, :html_form_type
  end
end
