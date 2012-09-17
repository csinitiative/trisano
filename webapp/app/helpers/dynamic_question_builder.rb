class DynamicQuestionBuilder

  def initialize(options={})
    @question_element = options.fetch(:question_element)
    @form_elements_cache = options.fetch(:form_elements_cache)
  end

  def question_is_multi_valued_and_has_no_value_set?
    if question.is_multi_valued?
      !@form_elements_cache.has_children_for?(@question_element) ||
      !@form_elements_cache.has_value_set_for?(@question_element)
    end    
  end   


  private

  def question
    @question_element.question
  end
end
