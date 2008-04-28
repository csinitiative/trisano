class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :form_element_id  # FK to form_elements
      t.string  :question_text, :limit => 255
      t.string  :help_text, :limit => 255
      t.string  :data_type, :limit =>  50 # One of single_line_text, text_area, single_select, multi_select
      t.integer :size
      t.string :condition, :limit => 255
      t.string  :display_as, :limit =>  50  # One of radio_button, check_box, drop_down, multi_select
      t.boolean :is_on_short_form
      t.boolean :is_required
      t.boolean :is_exportable
      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
