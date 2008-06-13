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
          result << ["show", follow_up]
        else
          result << ["hide", follow_up]
        end
          
      end
    end
        
    result
  end
    
end
