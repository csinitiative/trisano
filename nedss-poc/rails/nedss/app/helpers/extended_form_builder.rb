class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def dropdown_code_field(attribute, code_name, options ={}, html_options ={}, event =nil)
    
    unless (@object.nil? || event.nil?)
      
      # Debt: Duplicating this logic
      can_investigate = ((event.under_investigation? or event.reopened?) and User.current_user.is_entitled_to_in?(:investigate, event.active_jurisdiction.secondary_entity_id) and !event.disease.disease_id.nil? )

      if (can_investigate && !event.form_references.nil?)

        event.form_references.each do |form_reference|
          if (form_reference.form.form_base_element.all_cached_follow_ups_by_core_path("#{@object_name}[#{attribute}]").size > 0)
              p "Include event handler"
              break
          end
        end
      end
    end

    self.collection_select(attribute, codes(code_name), :id, :code_description, options, html_options)

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

    # Selection-type elements must have a value set
    if [:drop_down, :check_box, :radio_button].include? question.data_type 
      if question_element.children.empty?
        return ""
      else
        if question_element.children.first.children.empty?
          return ""
        end
      end
    end

    event_id = (@object.nil? || @object.event_id.blank?) ? "" : @object.event_id
    index = @object.id.nil? ? index : @object.id
    html_options[:index] = index

    # Debt: Is this issuing an extra query? We have children in memory already.
    follow_ups = question_element.children_by_type("FollowUpElement")

    if(follow_ups.size > 0)
      conditions = []
      follow_ups.each { |follow_up| conditions << "#{follow_up.condition},#{follow_up.id}"}
      conditions = conditions.join(",")
      text_answer_event = "sendConditionRequest(this, '#{event_id}', '#{question_element.id}');"
      select_answer_event = "sendConditionRequest(this, '#{event_id}', '#{question_element.id}');"
    end

    input_element = case question.data_type
    when :single_line_text
      html_options[:size] = question.size
      html_options[:onchange] = text_answer_event if follow_ups
      text_field(:text_answer, html_options)
    when :multi_line_text
      html_options[:rows] = 3
      html_options[:onchange] = text_answer_event if follow_ups
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
    when :radio_button
      i = 0
      name = @object_name + "[" + index.to_s + "][radio_button_answer][]"
      get_values(question_element).inject(radio_buttons = "") do |radio_buttons, value|
        id = @object_name.gsub(/[\[\]]/, "_") + "_" + index.to_s + "_radio_button_answer_#{i += 1}" 
        radio_buttons += @template.radio_button_tag(name, value, @object.radio_button_answer.include?(value), :id => id) + value
      end
      radio_buttons += @template.hidden_field_tag(name, "")
    when :date
      html_options[:onchange] = text_answer_event if follow_ups
      calendar_date_select(:text_answer, html_options)
    when :phone
      html_options[:size] = 14
      html_options[:onchange] = text_answer_event if follow_ups
      text_field(:text_answer, html_options)
    end

    q = if question.data_type == :check_box || question.data_type == :radio_button
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
