class Question < ActiveRecord::Base
  
  belongs_to :question_element, :foreign_key => "form_element_id"
  
  validates_presence_of :question_text
  validates_presence_of :data_type, :unless => :core_data
  validates_presence_of :core_data_attr, :if => :core_data

  def data_type
    read_attribute("data_type").to_sym unless read_attribute("data_type").blank?
  end

end
