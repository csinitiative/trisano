class Question < ActiveRecord::Base
  
  belongs_to :question_element
  
  attr_accessor :parent_id 
  
  validates_presence_of :question_text, :data_type
  
  def save_and_add_to_form!(parent_element_id)
    parent_element = FormElement.find(parent_element_id)
    question_element = QuestionElement.create(:form_id => parent_element.form_id)
    parent_element.add_child(question_element)
    self.question_element_id = question_element.id
    self.save!
  end
  
end
