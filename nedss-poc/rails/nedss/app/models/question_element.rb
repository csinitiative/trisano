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
  
  def process_condition(answer, event_id)
    result = nil
    
    # Debt: This could go against the cache
    follow_ups = self.children_by_type("FollowUpElement")
    
    if (answer.is_a? Answer)
      condition = answer.text_answer
    else
      condition = answer[:response]
    end
    
    follow_ups.each do |follow_up|
      if (follow_up.condition == condition)
        result = follow_up
      else
        unless (event_id.blank?)
          # Debt: We could add a method that does this against the cache
          question_elements_to_delete = QuestionElement.find(:all, :include => :question,
            :conditions => ["lft > ? and rgt < ? and tree_id = ?", follow_up.lft, follow_up.rgt, follow_up.tree_id])
          
          question_elements_to_delete.each do |question_element|
            answer = Answer.find_by_event_id_and_question_id(event_id, question_element.question.id)
            answer.destroy unless answer.nil?
          end
        end
      end
    end
    
    result
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
