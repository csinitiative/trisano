class Question < ActiveRecord::Base
  belongs_to :question_type
  belongs_to :group
  belongs_to :follow_up_group, :class_name => 'Group'
  has_one :answer_set
  
  acts_as_list :scope => :group
  
  validates_presence_of :text, :question_type
  
  def process_conditional(response)
     (self.condition == response) ?  Group.find(self.follow_up_group_id) : nil
  end
  
end
