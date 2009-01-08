# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class ExtendedFormBuilder < ActionView::Helpers::FormBuilder

  def core_text_field(attribute, options = {}, event =nil)
    core_follow_up(attribute, options, event) do |attribute, options|
      text_field(attribute, options)
    end
  end
  
  def core_calendar_date_select(attribute, options = {}, event =nil)
    core_follow_up(attribute, options, event) do |attribute, options|
      calendar_date_select(attribute, options)
    end
  end
  
  def dropdown_code_field(attribute, code_name, options ={}, html_options ={}, event =nil)
    core_follow_up(attribute, html_options, event) do |attribute, html_options|
      options[:include_blank] = true unless options[:include_blank] == false
      self.collection_select(attribute, codes(code_name), :id, :code_description, options, html_options)
    end
  end

  def core_dropdown_field(attribute, collection, value_method, text_method, options={}, html_options={}, event=nil)
    core_follow_up(attribute, html_options, event) do |attribute, html_options|
      options[:include_blank] = true unless options[:include_blank] == false
      self.collection_select(attribute, collection, value_method, text_method, options, html_options)
    end
  end

  def multi_select_code_field(attribute, code_name, options, html_options)
    html_options[:multiple] = true
    self.collection_select(attribute, codes(code_name), :id, :code_description, options, html_options)
  end

  def codes(code_name)
    if(is_external_code?(code_name))
      @external_codes = ExternalCode.find(:all, :order => 'sort_order')
      @ret = @external_codes.select {|code| code.code_name == code_name}
    else
      @codes = Code.find(:all, :order => 'sort_order')

      # DEBT:  Clean this up some day, but for now remove the 'jurisdiction' code type so that the user
      # doesn't accidentally create one.
      @codes.delete_if { |code| code.the_code == 'J' } if code_name == 'placetype'

      @ret = @codes.select {|code| code.code_name == code_name}
    end
    @ret
  end

  # TODO: refactor me! 
  def dynamic_question(form_elements_cache, question_element, event, index, html_options = {}) 
    id = html_options[:id]
    result = ""
    question = question_element.question
    
    if [:drop_down, :check_box, :radio_button].include? question.data_type 
      if form_elements_cache.children(question_element).empty?
        return ""
      else
        value_set = form_elements_cache.children_by_type("ValueSetElement", question_element).first
        if (value_set.nil? || form_elements_cache.children(value_set).empty?)
          return ""
        end
      end
    end
    
    index = @object.id.nil? ? index : @object.id
    html_options[:index] = index

    follow_ups = form_elements_cache.children_by_type("FollowUpElement", question_element)

    if(follow_ups.size > 0)
      conditions = []
      follow_ups.each { |follow_up| conditions << "#{follow_up.condition},#{follow_up.id}"}
      conditions = conditions.join(",")
      text_answer_event = "sendConditionRequest(this, '#{event.id}', '#{question_element.id}');"
      select_answer_event = "sendConditionRequest(this, '#{event.id}', '#{question_element.id}');"
    end

    cdc_attributes = []
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
      select_values = []
      get_values(form_elements_cache, question_element).each do |value_hash|
        unless question_element.export_column.blank?
          cdc_attributes << {:value => value_hash[:value], :export_conversion_value_id => value_hash[:export_conversion_value_id]}
        end
        select_values << value_hash[:value]
      end
      select(:text_answer, select_values, {}, html_options)
    when :check_box
      
      if @object.new_record?
        field_name = "#{@object_name[0...(@object_name.index("["))]}[new_checkboxes]"
        field_index = question.id.to_s
      else
        field_name = @object_name
        field_index = index.to_s
      end
      
      i = 0
      name = field_name + "[" + field_index + "][check_box_answer][]"
      get_values(form_elements_cache, question_element).inject(check_boxes = "") do |check_boxes, value_hash|
        html_options[:id] =  "#{id}_#{i += 1}"
        check_boxes += @template.check_box_tag(name, value_hash[:value], @object.check_box_answer.include?(value_hash[:value]), html_options) + value_hash[:value]
      end
      check_boxes += @template.hidden_field_tag(name, "")
    when :radio_button
      
      if @object.new_record?
        field_name = "#{@object_name[0...(@object_name.index("["))]}[new_radio_buttons]"
        field_index = question.id.to_s
      else
        field_name = @object_name
        field_index = index.to_s
      end
      
      i = 0
      name = field_name + "[" + field_index + "][radio_button_answer][]"
      
      get_values(form_elements_cache, question_element).inject(radio_buttons = "") do |radio_buttons, value_hash|
        
        html_options[:id] =  "#{id}_#{i += 1}"
        html_options[:onchange] = select_answer_event if follow_ups
        
        unless question_element.export_column.blank?
          cdc_attributes << {:id => html_options[:id], :export_conversion_value_id => value_hash[:export_conversion_value_id]}
        end
        
        radio_buttons += @template.radio_button_tag(name, value_hash[:value], @object.radio_button_answer.include?(value_hash[:value]), html_options) + value_hash[:value]        
      end
      radio_buttons += @template.hidden_field_tag(name, "")
    when :date
      html_options[:onchange] = text_answer_event if follow_ups
      html_options[:year_range] = 100.years.ago..0.years.from_now
      calendar_date_select(:text_answer, html_options)
    when :phone
      html_options[:size] = 14
      html_options[:onchange] = text_answer_event if follow_ups
      text_field(:text_answer, html_options) + "&nbsp;<small>10 digits with optional delimiters. E.g. 9999999999 or 999-999-9999</small>"
    end

    if question.data_type == :check_box || question.data_type == :radio_button
      result += @template.content_tag(:label, question.question_text) + " " + input_element      
      result += "\n" + hidden_field(:question_id, :index => index) unless @object.new_record?
      unless question_element.export_column.blank?
        result += "\n" + @template.hidden_field_tag(field_name + "[#{field_index}]" + '[export_conversion_value_id]', export_conversion_value_id(event, question)) 
        result += rb_export_js(cdc_attributes, field_name + "[#{field_index}]" + '[export_conversion_value_id]')
      end
    else
      result += @template.content_tag(:label) do
        question.question_text 
      end
      result += input_element
      result += "\n" + hidden_field(:question_id, :index => index)
      unless question_element.export_column.blank?
        if question.data_type == :drop_down
          result += "\n" + @template.hidden_field_tag(object_name + "[#{index}]" + '[export_conversion_value_id]', export_conversion_value_id(event, question)) 
          result += dd_export_js(cdc_attributes, object_name + "[#{index}]" + '[export_conversion_value_id]', id)
        else
          result += "\n" + hidden_field(:export_conversion_value_id, :index => index, :value => question_element.export_column.export_conversion_values.first.id )
        end
      end
    end

    result << follow_up_spinner_for(id)
    
    result
  end

  def get_values(form_elements_cache, question_element)
    form_elements_cache.children(form_elements_cache.children(question_element).find { |child| child.is_a?(ValueSetElement) }).collect { |value| {:value => value.name, :export_conversion_value_id => value.export_conversion_value_id} }
  end
  
  private

  def core_follow_up(attribute, options = {}, event = nil)
    change_event = core_follow_up_event(attribute, event)
    options[:onchange] = change_event unless change_event.blank?    
    spinner = change_event.blank? ? '' : follow_up_spinner_for(core_path[attribute])
    field = block_given? ? yield(attribute, options) : ''
    field + spinner
  end

  def is_external_code?(code_name)
    @external_codes = ["gender", "ethnicity", "state", "county","specimen", "imported", "yesno", "location", "language", "race", "case", "telephonelocationtype", "contactdispositiontype", "contact_type", "lab_interpretation"]
    @external_codes.each {|ec| return TRUE if ec == code_name}
    return FALSE
  end

  def core_follow_up_event(attribute, event)
    return if  (event.nil? || event.form_references.nil?) 
    result = ""

    unless (core_path.nil?)
      event.form_references.each do |form_reference|
        if (form_reference.form.form_element_cache.all_follow_ups_by_core_path("#{core_path[attribute]}").size > 0)
          result = "sendCoreConditionRequest(this, '#{event.id}', '#{core_path[attribute]}');"
          break
        end
      end
    end
    return result
  end

  def core_path
    core_path = @options[:core_path] || @object_name
    return if core_path.nil?
    CorePath[core_path]
  end

  def follow_up_spinner_for(id)
    '&nbsp;' * 2 + @template.image_tag('redbox_spinner.gif', :id => "#{id}_spinner", :alt => 'Working...', :size => '16x16', :style => 'display: none;')
  end    

  def conversion_id_for(question_element, value_from)
    question_element.export_column.export_conversion_values.each do |conversion_value|
      if conversion_value.value_from == value_from
        return conversion_value.id
      end
    end
  end

  def rb_export_js(radio_buttons, id)
    script = "<script type=\"text/javascript\">\n"
    script << "Event.observe(window, 'load', function() {\n"    

    radio_buttons.each do |radio_button|
      script << "$('#{radio_button[:id]}').observe('click', function() { "
      script << "$('#{id}').writeAttribute('value', '#{radio_button[:export_conversion_value_id]}') });\n"
    end
    
    script << "});</script>\n"
    script
  end

  def dd_export_js(option_elements, hidden_conversion_field, id)
    script = "<script type=\"text/javascript\">\n"
    script << "Event.observe(window, 'load', function() {\n"    

    script << "$('#{id}').observe('change', function() {\n"
    option_elements.each do |option_element|
      script << "  if (this.value == '#{option_element[:value]}') { "
      script << "$('#{hidden_conversion_field}').writeAttribute('value', '#{option_element[:export_conversion_value_id]}') }\n"
    end
    
    script << "}); });</script>\n"
    script
  end

  def export_conversion_value_id(event, question)
    answer = event.answers.find_by_question_id(question.id)
    answer.export_conversion_value_id unless answer.nil?
  end

end

class CorePath

  class << self
    def [](base)
      new base
    end
  end

  def [](attribute)
    @path += "[#{attribute}]"
    self
  end

  def to_s
    @path
  end

  private 
  
  def initialize(base)
    @path = base
  end

end
