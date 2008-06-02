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
        self.tree_id = parent_element.tree_id
        self.save
        parent_element.add_child(self)
      end
    end
  end

  def question_instance
    @question_instance || question
  end
  
  def question_attributes=(question_attributes)
    if new_record?
      @question_instance = Question.new(question_attributes)
    else
      question_instance.update_attributes(question_attributes)
    end
  end

  def is_multi_valued?
    question_instance.data_type == :drop_down || question_instance.data_type == :radio_button || question_instance.data_type == :check_box
  end

  def is_multi_valued_and_empty?
    is_multi_valued? && (children_count_by_type("ValueSetElement") == 0)
  end
  
end
