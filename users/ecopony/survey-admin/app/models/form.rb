class Form < ActiveRecord::Base
  belongs_to :disease
  belongs_to :jurisdiction
  
  has_many :sections, :order => :position
  
  validates_presence_of :disease
  validates_presence_of :jurisdiction
  
  def self.save_responses(params)
    
    form = Form.find(params[:id])
    
    form.sections.each do |section|
      section.groups.each do |group|
        group.questions.each do |question|
          
          response = Response.new({:cmr_id => params[:cmr_id], :form_id => params[:id], :question_id => params[:question_id]})
          form_field_value = params["question_#{question.id}"]
          
          if question.answer_set.nil?
            response.response = form_field_value
          else
            response.answer_id = form_field_value.to_i
          end
          
          response.save!
          
        end
      end
    end
  end
  
end
