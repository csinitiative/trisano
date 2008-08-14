module FormElementsHelper
  
  def condition_autocomplete
    model_auto_completer "follow_up_element[condition]", 
          @follow_up_element.condition, 
          "follow_up_element[condition_id]", 
         @follow_up_element.condition, 
          { :allow_free_text => true, :append_random_suffix => true, :action => 'auto_complete_for_core_follow_up_conditions'},
          { :size => 25 }, 
          { :skip_style => false }
  end
end
