class AnswerSetElement < FormElement
  
  attr_accessor :parent_element_id
  
  after_create :move_under_parent
  
  def move_under_parent
    parent_element = FormElement.find(self.parent_element_id)
    parent_element.add_child(self)
  end
  
end
