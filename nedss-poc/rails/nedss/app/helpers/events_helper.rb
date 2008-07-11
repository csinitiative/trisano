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
    
    form_elements_cache = FormElementCache.new(view)
    
    form_elements_cache.children.each do |element|
      result += render_investigator_element(form_elements_cache, element, f)
    end
    
    result
  end
  
  def add_lab_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "labs", :partial => 'lab' , :object => Participation.new_lab_participation
    end
  end

  def add_hospital_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "hospitals", :partial => 'hospital' , :object => Participation.new_hospital_participation
    end
  end

  def add_diagnostic_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "diagnostics", :partial => 'diagnostic' , :object => Participation.new_diagnostic_participation
    end
  end

  private
  
  def render_investigator_element(form_elements_cache, element, f)
    result = ""
    
    case element.class.name
   
    when "SectionElement"
      result += render_investigator_section(form_elements_cache, element, f)
    when "GroupElement"
      result += render_investigator_group(form_elements_cache, element, f)
    when "QuestionElement"
      result += render_investigator_question(form_elements_cache, element, f)
    when "FollowUpElement"
      result += render_investigator_follow_up(form_elements_cache, element, f)
    end
    
    result
  end
  
  def render_investigator_section(form_elements_cache, element, f)
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
    
    section_children = form_elements_cache.children(element)
    
    if section_children.size > 0
      section_children.each do |child|
        result += render_investigator_element(form_elements_cache, child, f)
      end
    end
    
    result += "</div></fieldset><br/>"
    
    result
  end
  
  def render_investigator_group(form_elements_cache, element, f)
    result = ""

    group_children = form_elements_cache.children(element)
    
    if group_children.size > 0
      group_children.each do |child|
        result += render_investigator_element(form_elements_cache, child, f)
      end
    end

    result
  end

  def render_investigator_question(form_elements_cache, element, f)
    
    result = "<div id='question_investigate_#{element.id}'>"
    
    @answer_object = @event.get_or_initialize_answer(element.question.id)
     
    if (f.nil?)
      result += fields_for(@event) do |f|
        f.fields_for(:new_answers, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
          answer_template.dynamic_question(form_elements_cache, element, "", {:id => "investigator_answer_#{element.id}"})
        end
      end
    else
      prefix = @answer_object.new_record? ? "new_answers" : "answers"
      index = @answer_object.new_record? ? "" : @form_index += 1
      result += f.fields_for(prefix, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
        answer_template.dynamic_question(form_elements_cache, element, index, {:id => "investigator_answer_#{element.id}"})
      end
    end

    # Debt: Re-retrieving something already in the tree; just need to look at the kids
    follow_up_group = element.process_condition(@answer_object, @event.id)
      
    unless follow_up_group.nil?
      result += "<div id='follow_up_investigate_#{element.id}'>"
      result += render_investigator_follow_up(form_elements_cache, follow_up_group, f)
      result += "</div>"
    else
      result += "<div id='follow_up_investigate_#{element.id}'></div>"
    end
    
    result += "</div>"
    
    result
  end
  
  def render_investigator_follow_up(form_elements_cache, element, f)
    result = ""
    
    unless element.core_path.blank?
      result += render_investigator_core_follow_up(form_elements_cache, element, f) unless element.core_path.blank?
      return result
    end
    
    questions = form_elements_cache.children(element)
    
    if questions.size > 0
      questions.each do |child|
        result += render_investigator_question(form_elements_cache, child, f)
      end
    end

    result
  end
  
  def render_investigator_core_follow_up(form_elements_cache, element, f, ajax_render =false)
    result = ""
    
    include_children = false
    
    unless (ajax_render)
      # Debt: Replace with shorter eval technique
      core_path_with_dots = element.core_path.sub("event[", "").gsub(/\]/, "").gsub(/\[/, ".")
      core_value = @event
      core_path_with_dots.split(".").each do |method|
        begin
          core_value = core_value.send(method)
        rescue
          break
        end
        
      end

      if (element.condition == core_value.to_s)
        include_children = true
      end
    end
    
    result += "<div id='follow_up_investigate_#{element.id}'>" unless ajax_render
    
    if (include_children || ajax_render)
      questions = form_elements_cache.children(element)
    
      if questions.size > 0
        questions.each do |child|
          result += render_investigator_question(form_elements_cache, child, f)
        end
      end
    end

    result += "</div>" unless ajax_render
    
    result
  end
  
end
