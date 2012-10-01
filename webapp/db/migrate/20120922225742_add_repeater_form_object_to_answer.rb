class AddRepeaterFormObjectToAnswer < ActiveRecord::Migration
  def self.up
    remove_column :form_elements, :repeater_form_object_type
    remove_column :form_elements, :repeater_form_object_id
    add_column :answers, :repeater_form_object_id, :integer
    add_column :answers, :repeater_form_object_type, :string
    execute("DROP INDEX answers_unique_question_and_event;")
    execute("CREATE UNIQUE INDEX answers_unique_question_and_event ON answers (event_id, question_id, repeater_form_object_id, repeater_form_object_type);")
  end

  def self.down
    execute("DROP INDEX answers_unique_question_and_event;")
    execute("CREATE UNIQUE INDEX answers_unique_question_and_event ON answers (event_id, question_id);")
    remove_column :answers, :repeater_form_object_type
    remove_column :answers, :repeater_form_object_id
    add_column :form_elements, :repeater_form_object_id, :integer
    add_column :form_elements, :repeater_form_object_type, :string
  end
end
