module FormsHelper
  
  def render_element(element, include_children=true)
    
    result = ""
    
    case element.class.name
    
    when "ViewElement"
      result += render_view(element, include_children)
    when "CoreViewElement"
      result += render_core_view(element, include_children)
    when "SectionElement"
      result += render_section(element, include_children)
    when "QuestionElement"
      result += render_question(element, include_children)
    when "ValueSetElement"
      result += render_value_set(element, include_children)
    when "ValueElement"
      result += render_value(element, include_children)
    end
    
    return result
  end
  
  def render_view(element, include_children=true)
    
    result = ""
    
    result += "<li id='section_" + element.id.to_s + "'><b>"
    result += element.name
    result += "</b>"
    
    if include_children && element.children?
      result += "<ul id='view_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += add_section_link(element)

    result += "</li>"
    
    result
  end
  
  def render_core_view(element, include_children)
    result = ""
    
    result += "<li id='section_" + element.id.to_s + "'><b>"
    result += element.name + " Tab"
    result += "</b>"
    
    if element.children?
      result += reorder_question_link(element)
    end
    
    if include_children && element.children?
      result += "<ul id='view_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += add_section_link(element)
    result += add_question_link(element)
    
    result += "</li>"
    
    result
  end
  
  def render_section(element, include_children=true)
    
    result = ""
    
    result += "<li id='section_" + element.id.to_s + "'><b>"
    result += element.name
    result += "</b>"
    
    if element.children?
      result += reorder_question_link(element)
    end
    
    if include_children && element.children?
      result += "<ul id='section_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += add_question_link(element)
    result += add_core_data_link(element)

    result += "</li>"
    
    result
  end
  
  def render_question(element, include_children=true)
    
    result = ""
    question = element.question
    
    result += "<li id='question_" + element.id.to_s + "'>Question: "
    result += question.question_text
    
    if (include_children && (question.data_type != :single_line_text && question.data_type != :multi_line_text && 
            question.data_type != :date && question.data_type != :phone) && element.children? == false)
      result += "<br/>"
      result += "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/new?form_element_id=" + 
        element.id.to_s + "&form_id=" + element.form_id.to_s  + "', {asynchronous:true, evalScripts:true}); return false;\">Add value set</a></small>"
    end
    
    if include_children && element.children?
      result += "<ul id='question_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += "</li>"
    
    result
  end
  
  def render_value_set(element, include_children=true)
    result = ""
    
    result += "<li id='value_set_" + element.id.to_s + "'>Value Set: "
    result += element.name
    
    if include_children && element.children?
      result += "<ul id='value_set_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child, include_children)
      end
      result += "</ul>"
    end
    
    result += "<small><a href='#' onclick=\"new Ajax.Request('../../value_set_elements/" + element.id.to_s + "/edit', {method:'get', asynchronous:true, evalScripts:true}); return false;\">Edit value set</a></small>"
    
    result += "</li>"
    
    result
  end
  
  def render_value(element, include_children=true)
    result = ""
    
    result += "<li id='value_" + element.id.to_s + "'>"
    result += "<span class='inactive-value'>" unless element.is_active
    result += element.name
    result += "&nbsp;<i>(Inactive)</i></span>" unless element.is_active
    result += "</li>"
    
    result
  end
  
  private
  
  def add_section_link(element)
    "<br /><small><a href='#' onclick=\"new Ajax.Request('../../section_elements/new?form_element_id=" + 
      element.id.to_s + "', {asynchronous:true, evalScripts:true}); return false;\">Add a section</a></small>"
  end

  def add_question_link(element)
    "<br /><small><a href='#' onclick=\"new Ajax.Request('../../questions/new?form_element_id=" + 
      element.id.to_s + "&core_data=false" + "', {asynchronous:true, evalScripts:true}); return false;\" id='add-question-" + 
      element.id.to_s + "' class='add-question' name='add-question'>Add a question</a></small>"
  end
  
  def add_core_data_link(element)
    "<br /><small><a href='#' onclick=\"new Ajax.Request('../../questions/new?form_element_id=" + 
      element.id.to_s + "&core_data=true" + "', {asynchronous:true, evalScripts:true}); return false;\">Add a core data element</a></small>"
  end
  
  def reorder_question_link(element)
    "<br/><small><a href='#' onclick=\"new Ajax.Request('../../forms/order_section_children_show/" + 
        element.id.to_s + "', {method:'get', asynchronous:true, evalScripts:true}); return false;\">Reorder questions</a></small>"
  end
  
end
