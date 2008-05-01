module FormsHelper
  
  def render_element(element)
    
    result = ""
    
    case element.class.name
      
    when "SectionElement"
      result += render_section(element)
    when "QuestionElement"
      result += render_question(element)
    when "AnswerSetElement"
      result += render_answer_set(element)
    when "AnswerElement"
      result += render_answer(element)
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
    
    result += "<br /><small><a href='#' onclick=\"new Ajax.Request('../../questions/new?form_element_id=" + 
      element.id.to_s + "', {asynchronous:true, evalScripts:true}); return false;\">Add a question</a></small>"
    
    result
  end
  
  def render_question(element)
    
    result = ""
    question = element.question
    
    result += "<li id='question_" + element.id.to_s + "'>Question: "
    result += question.question_text
    
    if ((question.data_type != :single_line_text && question.data_type != :multi_line_text && 
            question.data_type != :date && question.data_type != :phone) && element.children? == false)
      result += "<br/>"
      result += "<small><a href='#' onclick=\"new Ajax.Request('../../answer_set_elements/new?form_element_id=" + 
        element.id.to_s + "&form_id=" + element.form_id.to_s  + "', {asynchronous:true, evalScripts:true}); return false;\">Add answer set</a></small>"
    end
    
    result += "</li>"
    
    if element.children?
      result += "<ul id='question_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child)
      end
      result += "</ul>"
    end
    
    result
  end
  
  def render_answer_set(element)
    result = ""
    
    result += "<li id='answer_set_" + element.id.to_s + "'>Answer Set: "
    result += element.name
    
    if element.children?
      result += "<ul id='answer_set_" + element.id.to_s + "_children'>"
      element.children.each do |child|
        result += render_element(child)
      end
      result += "</ul>"
    end
    
    result += "</li>"
    
    result
  end
  
  def render_answer(element)
    result = ""
    
    result += "<li id='answer_" + element.id.to_s + "'>"
    result += element.name
    result += "</li>"
    
    result
  end
  
end
