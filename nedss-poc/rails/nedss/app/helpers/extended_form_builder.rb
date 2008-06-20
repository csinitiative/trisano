class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def core_text_field(attribute, options = {}, event =nil)
    change_event = core_follow_up_event(attribute, event)
    options[:onchange] = change_event unless change_event.blank?
    text_field(attribute, options)
  end
  
  def core_calendar_date_select(attribute, options = {}, event =nil)
    change_event = core_follow_up_event(attribute, event)
    options[:onchange] = change_event unless change_event.blank?
    calendar_date_select(attribute, options)
  end
  
  def dropdown_code_field(attribute, code_name, options ={}, html_options ={}, event =nil)
    
    change_event = core_follow_up_event(attribute, event)
    html_options[:onchange] = change_event unless change_event.blank?
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

  def dynamic_question(form_elements_cache, question_element, index, html_options = {}) 
        
    question = question_element.question

    # Defect: These need to filter on value sets so as not to be thrown off by follow ups
    # Selection-type elements must have a value set
    if [:drop_down, :check_box, :radio_button].include? question.data_type 
      if form_elements_cache.children(question_element).empty?
        return ""
      else
        if form_elements_cache.children(form_elements_cache.children(question_element).first).empty?
          return ""
        end
      end
    end

    event_id = (@object.nil? || @object.event_id.blank?) ? "" : @object.event_id
    index = @object.id.nil? ? index : @object.id
    html_options[:index] = index

    follow_ups = form_elements_cache.children_by_type("FollowUpElement", question_element)

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
      select(:text_answer, get_values(form_elements_cache, question_element), {}, html_options)
    when :check_box
      
      if @object.new_record?
        field_name = "event[new_checkboxes]"
        field_index = question.id.to_s
      else
        field_name = @object_name
        field_index = index.to_s
      end
      
      i = 0
      name = field_name + "[" + field_index + "][check_box_answer][]"
      get_values(form_elements_cache, question_element).inject(check_boxes = "") do |check_boxes, value|
        id = @object_name.gsub(/[\[\]]/, "_") + "_" + field_index + "_check_box_answer_#{i += 1}"
        check_boxes += @template.check_box_tag(name, value, @object.check_box_answer.include?(value), :id => id) + value
      end
      check_boxes += @template.hidden_field_tag(name, "")
    when :radio_button
      
      if @object.new_record?
        field_name = "event[new_radio_buttons]"
        field_index = question.id.to_s
      else
        field_name = @object_name
        field_index = index.to_s
      end
      
      i = 0
      name = field_name + "[" + field_index + "][radio_button_answer][]"
      get_values(form_elements_cache, question_element).inject(radio_buttons = "") do |radio_buttons, value|
        id = @object_name.gsub(/[\[\]]/, "_") + "_" + field_index + "_radio_button_answer_#{i += 1}" 
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

    result = ""
    
    if question.data_type == :check_box || question.data_type == :radio_button
      result += @template.content_tag(:span, question.question_text, :class => "label") + " " + input_element
      
      result += "\n" + hidden_field(:question_id, :index => index) unless @object.new_record?
      
    else
      result += @template.content_tag(:label) do
        question.question_text + " " + input_element
      end
      result += "\n" + hidden_field(:question_id, :index => index)
    end

    result
  end

  def get_values(form_elements_cache, question_element)
    form_elements_cache.children(form_elements_cache.children(question_element).find { |child| child.is_a?(ValueSetElement) }).collect { |value| value.name }
  end
  
  private
  
  def core_follow_up_event(attribute, event)
    result = ""
    
    unless (@object.nil? || event.nil?)
      # Debt: Duplicating this logic
      can_investigate = ((event.under_investigation? or event.reopened?) and User.current_user.is_entitled_to_in?(:investigate, event.active_jurisdiction.secondary_entity_id) and !event.disease.disease_id.nil? )

      if (can_investigate && !event.form_references.nil?)        
        event.form_references.each do |form_reference|
          if (form_reference.form.form_base_element.all_cached_follow_ups_by_core_path("#{@object_name}[#{attribute}]").size > 0)
              result = "sendCoreConditionRequest(this, '#{event.id}', '#{@object_name}[#{attribute}]');"
              break
          end
        end
      end
    end
    return result
  end

end
