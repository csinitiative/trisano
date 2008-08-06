class CreatePublishedFormsTables < ActiveRecord::Migration
  def self.up
    create_table :published_form_elements do |t|
      t.integer :form_id
      t.string :type
      t.string :name
      t.string :description
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.timestamps
    end

    create_table :published_forms do |t|
      t.string :name
      t.string :description
      t.integer :disease_id
      t.integer :jurisdiction_id
      t.boolean :current
      t.string :version
      t.timestamps
    end

    create_table :published_questions do |t|
      t.integer :question_element_id  # FK to form_elements
      t.string  :question_text, :limit => 255
      t.string  :help_text, :limit => 255
      t.string  :data_type, :limit =>  50 # One of single_line_text, text_area, single_select, multi_select
      t.integer :size
      t.string  :condition, :limit => 255
      t.boolean :is_on_short_form
      t.boolean :is_required
      t.boolean :is_exportable
      t.timestamps
    end
  end

  def self.down
    drop_table :published_form_elements
    drop_table :published_forms
    drop_table :published_questions
  end
end
