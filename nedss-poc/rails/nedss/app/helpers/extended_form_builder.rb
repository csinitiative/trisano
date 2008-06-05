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

  def dynamic_question(question_element, index, html_options = {}) 
    question = question_element.question
    index = @object.id.nil? ? index : @object.id

    html_options[:index] = index

    # Debt: Is this issuing an extra query? We have children in memory already.
    follow_ups = question_element.children_by_type("FollowUpElement")

    if(follow_ups.size > 0)
      conditions = []
      follow_ups.each { |follow_up| conditions << "#{follow_up.condition},#{follow_up.id}"}
      conditions = conditions.join(",")
      text_answer_event = "process_follow_up_conditions(this, '#{conditions}')"
      select_answer_event = "process_follow_up_conditions(this, '#{conditions}')"
    end

    input_element = case question.data_type
    when :single_line_text
      html_options[:size] = question.size
      html_options[:onblur] = text_answer_event if follow_ups
      text_field(:text_answer, html_options)
    when :multi_line_text
      html_options[:rows] = 3
      html_options[:onblur] = text_answer_event if follow_ups
      text_area(:text_answer, html_options)
    when :drop_down
      html_options[:onchange] = select_answer_event if follow_ups
      # collection_select(:single_answer_id, question.value_sets, :id, :value, {}, html_options)
      select(:text_answer, get_values(question_element), {}, html_options)
    when :check_box
      i = 0
      name = @object_name + "[" + index.to_s + "][check_box_answer][]"
      get_values(question_element).inject(check_boxes = "") do |check_boxes, value|
        id = @object_name.gsub(/[\[\]]/, "_") + "_" + index.to_s + "_check_box_answer_#{i += 1}"
        check_boxes += @template.check_box_tag(name, value, @object.check_box_answer.include?(value), :id => id) + value
      end
      check_boxes + @template.hidden_field_tag(name, "")
    when :date
      html_options[:onblur] = text_answer_event if follow_ups
      calendar_date_select(:text_answer, html_options)
    when :phone
      html_options[:size] = 14
      html_options[:onblur] = text_answer_event if follow_ups
      text_field(:text_answer, html_options)
        
    end

    q = if question.data_type == :check_box
      @template.content_tag(:span, question.question_text, :class => "label") + " " + input_element
    else
      @template.content_tag(:label) do
        question.question_text + " " + input_element
      end
    end
      
    q + "\n" + hidden_field(:question_id, :index => index)
  end

  def get_values(question_element)
    question_element.children.find { |child| child.is_a?(ValueSetElement) }.children.collect { |value| value.name }
  end

end
