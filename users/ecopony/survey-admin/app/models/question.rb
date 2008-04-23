class Question < ActiveRecord::Base
  belongs_to :question_type
  belongs_to :group
  belongs_to :follow_up_group, :class_name => 'Group'
  has_one :answer_set
  
  acts_as_list :scope => :group
  
  validates_presence_of :text, :question_type
  
  def process_conditional(response)
    (self.condition == response && !self.follow_up_group_id.nil?) ?  Group.find(self.follow_up_group_id) : nil
  end
  
  def process_conditional!(params)
    follow_up_group = nil
    condition_match = (self.condition == params[:response])
    
    unless self.follow_up_group_id.nil?
      follow_up_group = Group.find(self.follow_up_group_id)
    
      unless condition_match
        follow_up_group.questions.each do |question|
          follow_up_response = Response.find_by_cmr_id_and_question_id(params[:cmr_id], question.id)
          follow_up_response.destroy unless follow_up_response.nil?
        end
      end
    end
    
    condition_match ? follow_up_group : nil

  end
end
