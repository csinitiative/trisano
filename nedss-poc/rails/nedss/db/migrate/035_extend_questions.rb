class ExtendQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :core_data, :boolean 
    add_column :questions, :core_data_attr, :string 
  end

  def self.down
    remove_column :questions, :core_data
    remove_column :questions, :core_data_attr
  end
end
