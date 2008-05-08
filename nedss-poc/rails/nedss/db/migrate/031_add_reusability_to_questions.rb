class AddReusabilityToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :is_template, :boolean
    add_column :questions, :template_id, :integer
  end

  def self.down
    remove_column :questions, :is_template
    remove_column :questions, :template_id
  end
end

