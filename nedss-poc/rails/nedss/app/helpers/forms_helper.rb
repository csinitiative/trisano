module FormsHelper
  
  def render_element(element)
    
    result = ""
    
    case element.class.name
      
    when "SectionElement"
      result += render_section(element)
    when "QuestionElement"
      result += render_question(element)
    end
    
    return result
  end
  
  def render_section(element)
    
    result = ""
    
    result += "<li id='section_" + element.id.to_s + "'><b>"
    result += element.name
    result += "</b></li>"
    
    if element.children?
      result += "<ul id='section_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child)
      end
      result += "</ul>"
    end
    
    result += "<br /><small><a href='#' onclick=\"new Ajax.Request('/questions/new?form_element_id=" + 
      element.id.to_s + "', {asynchronous:true, evalScripts:true}); return false;\">Add a question</a></small>"
    
    result
  end
  
  def render_question(element)
    
    result = ""
    question = element.question
    
    result += "<li id='question_" + element.id.to_s + "'>"
    result += question.question_text
    
    if ((question.data_type != "single_line_text" && question.data_type != "multi_line_text") && element.children? == false)
      result += "<br/>"
      result += "<small>Add answer set</small>"
    end
    
    result += "</li>"
    
    if element.children?
      element.children.each do |child|
        result += render_element(child)
      end
    end
    
    result
  end
  
end
