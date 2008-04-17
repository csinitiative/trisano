module FormsHelper
  
  def show_groups_link(name, groups)
    link_to_function name do |page|
      page.replace_html :groups, :partial => 'forms/groups', :object => groups
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
  
end
