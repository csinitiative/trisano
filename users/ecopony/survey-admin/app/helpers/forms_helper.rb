module FormsHelper
  
  def show_link(name, entity_name, object)
    link_to_function name do |page|
      page.replace_html entity_name, :partial => "forms/#{entity_name}", :object => object
    end
  end
  
  def draw_group_questions(group, responses)
    result = ""
    
    group.questions.each do |question|
      response = ""
    
      unless responses.nil?
        responses.each do |r|
          if r.question_id == question.id
            if question.answer_set.nil?
              response = r.response
            else
              response = r.answer_id
            end
          end
        end
      end
      
      result += question.text
      result += "<br/>"
      result += draw_investigator_form_element(question, response)
      result += "<br/><br/>"
      
      follow_up_group = question.process_conditional(response)
      
      unless follow_up_group.nil?
        result += "<div id='follow-up_#{question.id}'>"
        result += draw_group_questions(follow_up_group, responses)
        result += "</div>"
      else
        result += "<div id='follow-up_#{question.id}'></div>"
      end
      
    end
    
    result
  end
  
  # Duplicating just for expediency here
  def draw_investigator_form_element(question, response = "")
    
    if question.question_type.html_form_type == "input-text"
      result = "<input type='text' name='question_#{question.id}' value='#{response}' " 

      unless question.follow_up_group_id.nil?
        result += "onchange='sendConditionalRequest(this);'"
      end
        
      result += "/>"
      
    elsif question.question_type.html_form_type == "select"
      
      unless question.answer_set.nil?
        result = "<select name='question_#{question.id}'"
        
        unless question.follow_up_group_id.nil?
          result += "onchange='sendConditionalRequest(this);'"
        end
        
        result += ">"
        
        question.answer_set.answers.each do |answer|
          result += "<option value='#{answer.id}'"
          
          if answer.id == response
            result += " selected"
          end
          
          result += ">#{answer.text}</option>"
        end
      
        result += "</select>"
      
      end
    end
    
    result
  end
  
  def draw_form_element(question)
    
    if question.question_type.html_form_type == "input-text"
      result = "<input type='text' name='question_#{question.id}' value='' />"
      
    elsif question.question_type.html_form_type == "select"
      
      unless question.answer_set.nil?
        result = "<select name='question_#{question.id}'>"
        
        question.answer_set.answers.each do |answer|
          result += "<option value='#{answer.id}'>#{answer.text}</option>"
        end
      
        result += "</select>"
      end
    end
    
    result
  end
  
end
