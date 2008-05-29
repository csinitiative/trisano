class FormElement < ActiveRecord::Base
  acts_as_nested_set :scope => :tree_id
  belongs_to :form
  
  def destroy_with_dependencies
    transaction do
      if (self.class.name == "QuestionElement")
        self.question.destroy
      end
      self.destroy
    end
  end
  
  def children_count_by_type(type_name)
    FormElement.calculate(:count, :type, :conditions => ["type = ? and tree_id = ?", type_name, self.tree_id])
  end
  
  def children_by_type(type_name)
    FormElement.find(:all, :conditions => ["type = ? and parent_id = ?", type_name, self.id], :order => :lft)
  end
  
end
