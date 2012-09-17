class AddRepeaterFormObjectToQuestionElement < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :repeater_form_object_id, :integer
    add_column :form_elements, :repeater_form_object_type, :string
  end

  def self.down
    remove_column :form_elements, :repeater_form_object_type
    remove_column :form_elements, :repeater_form_object_id
  end
end
