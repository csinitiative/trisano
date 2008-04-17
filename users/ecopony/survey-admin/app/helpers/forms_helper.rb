module FormsHelper
  
  def show_groups_link(name, groups)
    link_to_function name do |page|
      page.replace_html :groups, :partial => 'forms/groups', :object => groups
    end
  end
  
  def draw_form_element(question)
    
    if question.question_type.html_form_type == "input-text"
      result = "<input type='text' name='' value='' />"
      
    elsif question.question_type.html_form_type == "select"
      
      if !question.answer_set.nil?
        result = "<select>"
      
        # Data driven blank option here
        
        question.answer_set.answers.each do |answer|
          result += "<option>#{answer.text}</option>"
        
          
        end
      
      
      result += "</select>"
      
      end
      
      
    end
    
    
    
    result
  end
  
end
