module AnswerSetElementsHelper
  
  def add_answer_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, 'answer-mods', :partial => 'answer_set_elements/answer', :object => AnswerElement.new
    end
  end
  
end
