class Question < ActiveRecord::Base
  
  belongs_to :question_element
  belongs_to :core_data_element, :foreign_key => "question_element_id"
  
  attr_accessor :parent_element_id, :core_data
  
  validates_presence_of :question_text
  validates_presence_of :data_type, :unless => :is_core_data 
  validates_presence_of :core_data_attr, :if => :is_core_data 
  
  def save_and_add_to_form(parent_element_id)
    if self.valid?
      transaction do
        parent_element = FormElement.find(parent_element_id)
        if is_core_data
          question_element = CoreDataElement.create(:form_id => parent_element.form_id)
        else
          question_element = QuestionElement.create(:form_id => parent_element.form_id)
        end
        parent_element.add_child(question_element)
        self.question_element_id = question_element.id
        a = self.save
      end
    end
  end

  def data_type
    read_attribute("data_type").to_sym unless read_attribute("data_type").blank?
  end

  def is_core_data
    core_data == "true" ? true : false
  end
end
