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
    section_open = false
    
    view.pre_order_walk do |element|

      case element.class.name
    
      when "SectionElement"
        result +=  "</div></fieldset>" if section_open
        section_open = true
        section_id = "section_investigate_#{element.id}";
        hide_id = section_id + "_hide";
        show_id = section_id + "_show"
        result +=  "<fieldset class='form_section'>"
        result += "<legend>#{element.name} "
        result += "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
        result += "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
        result += "</legend>"
        result += "<div id='#{section_id}'>"
      when "QuestionElement"
        if element.question.core_data
          result += render_core_data_element(element)
        else
          @answer_object = @event.get_or_initialize_answer(element.question.id)
          result += f.fields_for(:answers, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
            answer_template.dynamic_question(element, @form_index += 1)
          end
        end
      end
      
    end
    
    result += "</div></fieldset>" if section_open
    
    return result
  end
  
end
