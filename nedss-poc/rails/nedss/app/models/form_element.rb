class FormElement < ActiveRecord::Base
  acts_as_nested_set
  belongs_to :form
  
  def reorder_children(reorder_list)
    transaction do
      self.children.each do |child|
        child.move_to_position reorder_list.index(child.id.to_s)
      end
    end
  end
  
end
