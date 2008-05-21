class QuestionElement < FormElement
  has_one :question

  attr_accessor :parent_element_id
  
  validates_associated :question
  
  def save_and_add_to_form
    self.question = @question_instance
    if self.valid?
      transaction do
        parent_element = FormElement.find(parent_element_id)
        self.form_id = parent_element.form_id
        self.save
        parent_element.add_child(self)
      end
    end
  end

  def question_attributes=(question_attributes)
    if new_record?
      @question_instance = Question.new(question_attributes)
    end
  end
  
end
