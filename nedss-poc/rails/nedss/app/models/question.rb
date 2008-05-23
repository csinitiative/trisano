class Question < ActiveRecord::Base
  
  belongs_to :question_element
  
  validates_presence_of :question_text
  validates_presence_of :data_type, :unless => :core_data
  validates_presence_of :core_data_attr, :if => :core_data

  def data_type
    read_attribute("data_type").to_sym unless read_attribute("data_type").blank?
  end

#  def is_multi_valued?
#    question.data_type == :drop_down || question.data_type == :radio_button || question.data_type == :check_box
#  end

#  def is_multi_valued_and_empty?
#    is_multi_valued? && (element.children? == false)
#  end

end
