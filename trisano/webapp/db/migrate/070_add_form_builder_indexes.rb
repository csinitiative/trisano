class AddFormBuilderIndexes < ActiveRecord::Migration
  def self.up
    add_index(:form_elements, :tree_id, :name => "fe_tree_id_index")
    add_index(:form_elements, :parent_id, :name => "fe_parent_id_index")
    add_index(:questions, :form_element_id, :name => "q_form_element_id_index")
  end

  def self.down
    remove_index(:form_elements, :name => "fe_tree_id_index")
    remove_index(:form_elements, :name => "fe_parent_id_index")
    remove_index(:questions, :name => "q_form_element_id_index")
  end
end
