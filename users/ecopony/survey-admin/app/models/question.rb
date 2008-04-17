class Question < ActiveRecord::Base
  belongs_to :question_type
  belongs_to :group
  
  validates_presence_of :text, :question_type
end
