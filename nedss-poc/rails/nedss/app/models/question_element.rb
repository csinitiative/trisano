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

  # Nothing QuestionElement specific about this.  Should move up the hierarchy when stories appear.
  # DEBT! Should make publish and add_to_library the same code
  def add_to_library
    transaction do
      tree_id = QuestionElement.find_by_sql("SELECT nextval('tree_id_generator')").first.nextval.to_i
      copy_children(self, nil, tree_id)
      self.update_attribute(:in_library, true)
    end
  end

  def copy_children(node_to_copy, parent, tree_id)
      e = node_to_copy.class.new
      e.tree_id = tree_id
      e.is_template=true
      e.name = node_to_copy.name
      e.description = node_to_copy.description
      e.question = node_to_copy.question.clone if node_to_copy.is_a? QuestionElement
      e.save!
      parent.add_child e unless parent.nil?
      node_to_copy.children.each do |child|
        copy_children(child, e, tree_id)
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
    is_multi_valued? && (children? == false)
  end
  
end
