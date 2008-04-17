class Answer < ActiveRecord::Base
  belongs_to :answer_set
  
  acts_as_list :scope => :answer_set
  
end
