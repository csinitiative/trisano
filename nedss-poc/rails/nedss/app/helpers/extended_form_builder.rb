class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def dropdown_code_field(attribute, code_name, *args)
    self.collection_select(attribute, codes(code_name), :id, :code_description, *args)
  end

  def multi_select_code_field(attribute, code_name, options, html_options)
    html_options[:multiple] = true
    self.collection_select(attribute, codes(code_name), :id, :code_description, options, html_options)
  end

  def codes(code_name)
    @codes ||= Code.find(:all, :order => 'sort_order')
    @codes.select {|code| code.code_name == code_name}
  end

  def dynamic_question(question_element, answer_object, index) 
    question = question_element.question
#    q = @template.content_tag(:span, :class => "horiz") do
      q = @template.content_tag(:label) do
        index = answer_object.id.nil? ? index : answer_object.id

        html_options = {}
        html_options[:index] = index
# UNCOMMENT LATER
#        additional_questions = ! question.additional_questions_value.blank?
        additional_questions = false

        if additional_questions
          div_id = "additional_questions_for_question_#{question.id}"
          text_answer_event = "if (this.value == '#{question.additional_questions_value}') { Effect.Appear('#{div_id}') } else { Effect.Fade('#{div_id}') }"
          select_answer_event = "if (this.options[this.selectedIndex].text == '#{question.additional_questions_value}') { Effect.Appear('#{div_id}') } else { Effect.Fade('#{div_id}') }"
         # A little more work is needed for multi-selects, but it's within range.  Skipping for now.
        end

        input_element = case question.data_type
        when :single_line_text
          html_options[:size] = question.size
          html_options[:onblur] = text_answer_event if additional_questions
          text_field(:text_answer, html_options)
        when :multi_line_text
          html_options[:rows] = 3
          html_options[:onblur] = text_answer_event if additional_questions
          text_area(:text_answer, html_options)
        when :drop_down
          html_options[:onchange] = select_answer_event if additional_questions
          # collection_select(:single_answer_id, question.value_sets, :id, :value, {}, html_options)
          select(:text_answer, get_values(question_element), {}, html_options)
        when :date
          html_options[:onblur] = text_answer_event if additional_questions
          calendar_date_select(:text_answer, html_options)
        when :phone
          html_options[:size] = 14
          html_options[:onblur] = text_answer_event if additional_questions
          text_field(:text_answer, html_options)
          
#        when :multi_select
#          html_options[:onchange] = select_answer_event if additional_questions
#          html_options[:multiple] = true
#          collection_select(:value_set_ids, question.value_sets, :id, :value, {}, html_options)
        end

        question.question_text + " " + input_element 
      end
#    end
    q + "\n" + hidden_field(:question_id, :index => index)
  end

  def get_values(question_element)
    question_element.children.find { |child| child.is_a?(ValueSetElement) }.children.collect { |value| value.name }
  end

end
