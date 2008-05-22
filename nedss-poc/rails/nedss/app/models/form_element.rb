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
end
