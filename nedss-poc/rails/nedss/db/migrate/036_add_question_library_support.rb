class AddQuestionLibrarySupport < ActiveRecord::Migration
  def self.up
    add_column :form_elements, :in_library, :boolean
    add_column :form_elements, :tree_id, :integer
  
    execute "create sequence tree_id_generator"
  end



  def self.down
    remove_column :form_elements, :in_library
    remove_column :form_elements, :tree_id

    execute "drop sequence tree_id_generator"
  end
end
