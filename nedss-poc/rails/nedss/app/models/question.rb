class Question < ActiveRecord::Base
  
  belongs_to :question_element
  
  attr_accessor :parent_id

  before_create :initialize_form_elements
  
  validates_presence_of :question_text, :data_type
  
  def initialize_form_elements
    parent_element = FormElement.find(self.parent_id)
    question_element = QuestionElement.create(:form_id => parent_element.form_id)
    parent_element.add_child(question_element)
    self.question_element_id = question_element.id
  end
  
end
