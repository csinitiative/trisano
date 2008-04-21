class AddFormTemplateIdToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :form_template_id, :integer
  end

  def self.down
    remove_column :responses, :form_template_id
  end
end
