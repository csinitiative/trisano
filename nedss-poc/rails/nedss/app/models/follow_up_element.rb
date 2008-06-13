class FollowUpElement < FormElement
  
  attr_accessor :parent_element_id, :core_data
  
  validates_presence_of :condition
  
  def self.process_core_condition(params)
    result = []
    investigation_forms = []
    
    event = Event.find(params[:event_id])

    if event.form_references.blank?
      investigation_forms = event.get_investigation_forms
    else
      event.form_references.each do |form_reference|
        investigation_forms << form_reference.form
      end
    end
    
    investigation_forms.each do |form|
      form.form_base_element.all_cached_follow_ups_by_core_path(params[:core_path]).each do |follow_up|

        if (params[:response] == follow_up.condition)
          # Debt: The magic container for core follow ups needs to go probably
          result << ["show", follow_up]
        else
          result << ["hide", follow_up]
          
          unless (params[:event_id].blank?)
            # Debt: We could add a method that does this against the cache
            question_elements_to_delete = QuestionElement.find(:all, :include => :question,
              :conditions => ["lft > ? and rgt < ? and tree_id = ?", follow_up.lft, follow_up.rgt, follow_up.tree_id])
              
            question_elements_to_delete.each do |question_element|
              answer = Answer.find_by_event_id_and_question_id(params[:event_id], question_element.question.id)
              answer.destroy unless answer.nil?
            end
          end
        end
      end
    end
        
    result
  end
end
