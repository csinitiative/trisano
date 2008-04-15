class Question < ActiveRecord::Base
  belongs_to :question_type
  
  validates_presence_of :text, :question_type
end
