module FormsHelper
  
  def show_groups_link(name, groups)
    link_to_function name do |page|
      page.replace_html :groups, :partial => 'forms/groups', :object => groups
    end
  end
  
  def show_questions_link(name, questions)
    link_to_function name do |page|
      page.replace_html :questions, :partial => 'forms/questions', :object => questions
    end
  end
  
  def draw_form_element(question)
    
    if question.question_type.html_form_type == "input-text"
      result = "<input type='text' name='question_#{question.id}' value='' />"
      
    elsif question.question_type.html_form_type == "select"
      
      if !question.answer_set.nil?
        result = "<select name='question_#{question.id}'>"
        
        question.answer_set.answers.each do |answer|
          result += "<option value='#{answer.id}'>#{answer.text}</option>"
        end
      
        result += "</select>"
      end
    end
    
    result
  end
  
  # Duplicating just for expediency here
  def draw_investigator_form_element(question, responses)
    
    response = ""
    
    responses.each do |r|
      if r.question_id == question.id
        if question.answer_set.nil?
          response = r.response
        else
          response = r.answer_id
        end
      end
    end
    
    if question.question_type.html_form_type == "input-text"
      result = "<input type='text' name='question_#{question.id}' value='#{response}' />"
      
    elsif question.question_type.html_form_type == "select"
      
      if !question.answer_set.nil?
        result = "<select name='question_#{question.id}'>"
        
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
  
end
