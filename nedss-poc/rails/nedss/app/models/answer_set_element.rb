class AnswerSetElement < FormElement
  
  attr_accessor :parent_element_id
  
  def save_and_add_to_form!(parent_element_id)
    self.save!
    parent_element = FormElement.find(parent_element_id)
    parent_element.add_child(self)
  end
  
end
