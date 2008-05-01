class AnswerSetElement < FormElement
  
  attr_accessor :parent_element_id
  
  after_create :add_answers_to_hierarchy
  
  def answer_elements
    unless self.id.blank?
      return self.children
    else
      return []
    end
    
  end
  
  def save_and_add_to_form(parent_element_id)
    if self.valid?
      self.save
      parent_element = FormElement.find(parent_element_id)
      parent_element.add_child(self)
    end
  end
  
  def answer_attributes=(answer_attributes)
    @transient_answer_elements = []
    answer_attributes.each do |attributes|
      answer = AnswerElement.create(attributes)
      @transient_answer_elements << answer
    end
  end
  
  private
  
  def add_answers_to_hierarchy
    unless @transient_answer_elements.nil?
      @transient_answer_elements.each do |a|
        self.add_child a
      end
    end
  end
  
end
