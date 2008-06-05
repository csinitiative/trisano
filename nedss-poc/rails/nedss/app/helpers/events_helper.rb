module EventsHelper
  def render_core_data_element(element)
    question = element.question
    field_name = question.core_data_attr
    model_name = "@" + field_name.gsub("[", ".").gsub("]", "")
    id = field_name.chop.gsub(/[\[\]]/, "_") 
    data_type = Event.exposed_attributes[field_name][:type]
    value = eval model_name

    input_element = case data_type
    when :single_line_text
      text_field_tag(field_name, value, :id => id)
    when :text_area
      text_area_tag(field_name, value, :id => id)
    when :date
      calendar_date_select_tag(field_name, value, :id => id)
    end

    content_tag(:label) do
      question.question_text + " " + input_element
    end
    
  end
  
  def render_investigator_view(view, f)
    result = ""
    
    dfe = view.disconnected_form_element
    
    dfe.children_of(view).each do |element|
      result += render_investigator_element(dfe, element, f)
    end
    
    result
  end
  
  
  private
  
  def render_investigator_element(dfe, element, f)
    result = ""
    
    case element.class.name
   
    when "SectionElement"
      result += render_investigator_section(dfe, element, f)
    when "QuestionElement"
      result += render_investigator_question(dfe, element, f)
    when "FollowUpElement"
      result += render_investigator_follow_up(dfe, element, f)
    end
    
    result
  end
  
  def render_investigator_section(dfe, element, f)
    result = "<br/>"
    section_id = "section_investigate_#{element.id}";
    hide_id = section_id + "_hide";
    show_id = section_id + "_show"
    result +=  "<fieldset class='form_section'>"
    result += "<legend>#{element.name} "
    result += "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
    result += "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
    result += "</legend>"
    result += "<div id='#{section_id}'>"
    
    section_children = dfe.children_of(element)
    
    if section_children.size > 0
      section_children.each do |child|
        result += render_investigator_element(dfe, child, f)
      end
    end
    
    result += "</div></fieldset><br/>"
    
    result
  end
  
  def render_investigator_question(dfe, element, f, disabled=false)
    result = ""
    current_answer_text = ""
    
    if element.question.core_data
      result += render_core_data_element(element)
    else
      @answer_object = @event.get_or_initialize_answer(element.question.id)
      current_answer_text = @answer_object.text_answer
     
      result += f.fields_for(:answers, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
        answer_template.dynamic_question(element, @form_index += 1)
      end
    end
    
    follow_ups = dfe.children_of_by_type(element, "FollowUpElement")

    if follow_ups.size > 0
      follow_ups.each do |child|
        disabled = true
        unless current_answer_text.nil?
          if (current_answer_text == child.condition)
            disabled = false
          end
        end
        
        result += render_investigator_follow_up(dfe, child, f, disabled)
      end
    end
    
    result
  end
  
  def render_investigator_follow_up(dfe, element, f, disabled=false)
    result = ""
    
    display = disabled ? "none" : "inline"
    
    result += "<div style='display: #{display};' id='follow_up_investigate_#{element.id}'>"
    
    questions = dfe.children_of(element)
    
    if questions.size > 0
      questions.each do |child|
        result += render_investigator_question(dfe, child, f, disabled)
      end
    end
    
    result += "</div>"
    
    result
  end
  
end
