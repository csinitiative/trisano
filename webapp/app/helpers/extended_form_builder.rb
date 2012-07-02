# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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
require 'ostruct'

class ExtendedFormBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::SanitizeHelper
  include ActionController::UrlWriter
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods

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
      self.collection_select(attribute, codes(code_name.to_s), :id, :code_description, options, html_options)
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
    @template.codes_for_select(code_name)
  end

  # TODO: refactor me!
  def dynamic_question(form_elements_cache, question_element, event, index, html_options = {})
    id = html_options[:id]
    result = ""
    question = question_element.question

    if question.is_multi_valued?
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
      text_answer_event = "sendConditionRequest('#{process_condition_path}', this, '#{event.id}', '#{question_element.id}');"
      select_answer_event = "sendConditionRequest('#{process_condition_path}', this, '#{event.id}', '#{question_element.id}');"
    end

    cdc_attributes = []
    codes = []
    input_element = case question.data_type
    when :single_line_text
      unless (question.size.nil?)
        html_options[:maxlength] = question.size
        html_options[:size] = question.size
      end
      html_options[:onchange] = text_answer_event if follow_ups
      text_field(:text_answer, html_options)
    when :multi_line_text
      html_options[:rows] = 3
      html_options[:onchange] = text_answer_event if follow_ups
      text_area(:text_answer, html_options)
    when :drop_down
      field_name = @object_name
      field_index = @object.new_record? ? "" : index.to_s
      field_id = @object.new_record? ? question.id.to_s : index.to_s

      select_list = ""
      selected_code = ""

      html_options[:onchange] = select_answer_event if follow_ups
      select_values = []
      get_values(form_elements_cache, question_element).each do |value_hash|
        codes << {:value => value_hash[:value], :code => value_hash[:code]}
        if @object.text_answer
          selected_code = @object.text_answer == value_hash[:value] ? value_hash[:code] : "" unless !selected_code.blank?
        end

        unless question_element.export_column.blank?
          cdc_attributes << {:value => value_hash[:value], :export_conversion_value_id => value_hash[:export_conversion_value_id]}
        end
        select_values << value_hash[:value]
      end

      if selected_code.blank?
        selected_code = codes[0][:code]
      end

      select_list << select(:text_answer, select_values, {}, html_options)
      select_list << @template.hidden_field_tag(field_name + "[" + field_index + "][code]",
        selected_code,
        :id => field_name.gsub(/\[/, "_").gsub(/\]/, "") + "_#{field_id}_code"
      )
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
      selected_codes = []

      get_values(form_elements_cache, question_element).inject(check_boxes = "") do |check_boxes, value_hash|
        html_options[:id] =  "#{id}_#{i += 1}"
        codes << {:id => html_options[:id], :code => value_hash[:code]}
        selected_codes << value_hash[:code] if @object.check_box_answer.include?(value_hash[:value])
        check_boxes += @template.check_box_tag(name, value_hash[:value], @object.check_box_answer.include?(value_hash[:value]), html_options) + value_hash[:value]
        check_boxes += @template.hidden_field_tag("", value_hash[:code], { :id => "#{html_options[:id]}_code"})
      end
      check_boxes += @template.hidden_field_tag(name, "")
      check_boxes += @template.hidden_field_tag(field_name + "[" + field_index + "][code]", selected_codes.reject{|code|code.blank?}.join(","))
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
      selected_code = ""

      get_values(form_elements_cache, question_element).inject(radio_buttons = "") do |radio_buttons, value_hash|
        html_options[:id] =  "#{id}_#{i += 1}"
        html_options[:onclick] = select_answer_event if follow_ups
        codes << {:id => html_options[:id], :code => value_hash[:code]}

        unless question_element.export_column.blank?
          cdc_attributes << {:id => html_options[:id], :export_conversion_value_id => value_hash[:export_conversion_value_id]}
        end

        selected_code = @object.radio_button_answer.include?(value_hash[:value]) ? value_hash[:code] : "" unless !selected_code.blank?
        radio_buttons += @template.radio_button_tag(name, value_hash[:value], @object.radio_button_answer.include?(value_hash[:value]), html_options) + value_hash[:value]
      end
      radio_buttons += @template.hidden_field_tag(name, "")
      radio_buttons += @template.hidden_field_tag(field_name + "[" + field_index + "][code]", selected_code)
    when :date
      html_options[:onchange] = text_answer_event if follow_ups
      html_options[:year_range] = 100.years.ago..0.years.from_now
      html_options[:value] = @object.date_answer.strftime(I18n.t("date.formats.long")) unless @object.date_answer.nil?
      calendar_date_select(:text_answer, html_options)
    when :phone
      html_options[:size] = 14
      html_options[:onchange] = text_answer_event if follow_ups
      text_field(:text_answer, html_options) + "&nbsp;<small>#{I18n.t(:phone_answer_format_msg)}</small>"
    end

    if question.data_type == :check_box || question.data_type == :radio_button
      result += @template.content_tag(:label, sanitize(question.question_text, :tags => %w(br))) + " " + input_element
      result += "\n" + hidden_field(:question_id, :index => index) unless @object.new_record?
      result << code_js(codes, field_name.gsub(/\[/, "_").gsub(/\]/, "") + "_#{field_index}_code", question.data_type)

      unless question_element.export_column.blank?
        export_conv_field_name = field_name + "[#{field_index}]" + '[export_conversion_value_id]'
        export_conv_field_id = field_name.gsub(/\[/, "_").gsub(/\]/, "") + "_#{field_index}_" + 'export_conversion_value_id'
        result += "\n" + @template.hidden_field_tag(export_conv_field_name, export_conversion_value_id(event, question), :id => export_conv_field_id)
        result += rb_export_js(cdc_attributes, export_conv_field_id)
      end
    else
      result += @template.content_tag(:label, :for => html_options[:id]) do
        sanitize(question.question_text, :tags => %w(br))
      end
      result += input_element
      result += "\n" + hidden_field(:question_id, :index => index)
      unless question_element.export_column.blank?
        if question.data_type == :drop_down
          export_conv_field_name = object_name + "[#{index}]" + '[export_conversion_value_id]'
          export_conv_field_id = object_name.gsub(/\[/, "_").gsub(/\]/, "") + "_#{index}_" + 'export_conversion_value_id'
          result += "\n" + @template.hidden_field_tag(export_conv_field_name, export_conversion_value_id(event, question), :id => export_conv_field_id)
          result += dd_export_js(cdc_attributes, export_conv_field_id, id)
        else
          result += "\n" + hidden_field(:export_conversion_value_id, :index => index, :value => question_element.export_column.export_conversion_values.first.id )
        end
      end

      if question.data_type == :drop_down
        result << drop_down_code_js(codes, id, field_name.gsub(/\[/, "_").gsub(/\]/, "") + "_#{field_id}_code")
      end
    end

    result << follow_up_spinner_for(:id => id)

    result
  end

  def get_values(form_elements_cache, question_element)
    form_elements_cache.children(form_elements_cache.children(question_element).find { |child| child.is_a?(ValueSetElement) }).collect { |value| {:value => value.name, :export_conversion_value_id => value.export_conversion_value_id, :code => value.code} }
  end

  def core_path
    cp = @options[:core_path] || @object_name.to_s.gsub(/_attributes/,'').gsub(/\[\d+\]/, '')
    return if cp.nil?
    CorePath[cp]
  end

  def core_field(attribute)
    cp = core_path << attribute
    core_field = CoreField.event_fields(cp.first)[cp.to_s]
    if core_field
      core_field
    else
      CoreField::MissingCoreField.new(cp.to_s, true)
    end
  end

  def core_follow_up(attribute, options = {}, event = nil)
    returning [] do |result|
      core_follow_ups = follow_ups_for(attribute, event)
      core_follow_ups.each do |follow_up|
        #Because we must support FormElements which no longer apply to the current core_path
        #we pass in the historical follow_up element in order to build the follow up javascript call
        options[:onchange] = core_follow_up_event(follow_up, attribute, event)
        result << follow_up_spinner_for(attribute)
      end
      result.unshift(yield(attribute, options)) if block_given?
    end.join
  end

  def follow_ups_for(attribute, event)
    return [] unless core_path && event.try(:form_references)
    returning [] do |follow_ups|
      event.form_references.each do |fr|
        #setup follow ups for current event type
        path = core_path << attribute
        follow_ups << fr.form.form_element_cache.all_follow_ups_by_core_path("#{path.to_s}")

        #setup follow ups for previous event types
        event.event_type_transitions.each do |transition|
          historical_core_path_prefix = core_path.clone
          historical_core_path_prefix[0] = transition.was.underscore
          historical_core_path = historical_core_path_prefix << attribute
          follow_ups << fr.form.form_element_cache.all_follow_ups_by_core_path("#{historical_core_path.to_s}")
        end
        follow_ups #must end with follow_ups for returning
      end
    end.flatten
  end

  def core_follow_up_event(follow_up, attribute, event, value_attribute = nil)
    this_or_node = 'this'
    path = core_path << attribute
    follow_up_path = follow_up.core_path
    returning "" do |js|
      js << "sendCoreConditionRequest("
      js <<   "'#{process_core_condition_path}',"
      js <<   " #{this_or_node},"
      js <<   "'#{event.id}',"
      js <<   "'#{follow_up_path.to_s}',"
      js <<   "'#{path.underscore}_spinner'"
      js <<   ");"
    end
  end

  def follow_up_spinner_for(*args)
    options = args.extract_options!
    options.symbolize_keys!
    attribute = args.first
    spinner_id = (options[:id] || (core_path << attribute).underscore) + "_spinner"
    returning "" do |result|
      result << '&nbsp;' * 2
      result << @template.image_tag('redbox_spinner.gif',
        :id => spinner_id,
        :alt => 'Working...',
        :size => '16x16',
        :style => 'display: none;')
    end
  end

  def default_spinner_id(attribute)
    path = core_path << attribute
    "#{path.underscore}_spinner"
  end

  def conversion_id_for(question_element, value_from)
    question_element.export_column.export_conversion_values.each do |conversion_value|
      if conversion_value.value_from == value_from
        return conversion_value.id
      end
    end
  end

  def code_js(options, id, data_type)
    case data_type
    when :radio_button
      radio_button_code_js(options, id)
    when :check_box
      check_box_code_js(options, id)
    else
      ""
    end
  end

  def radio_button_code_js(radio_buttons, id)
    @template.on_loaded_or_eval do
      radio_buttons.collect do |radio_button|
        <<-JS
            $('#{radio_button[:id]}').observe('click', function() {
              $('#{id}').writeAttribute('value', '#{radio_button[:code]}')
            });
        JS
      end.join
    end
  end

  def check_box_code_js(check_boxen, id)
    @template.on_loaded_or_eval do
      check_boxen.collect do |check_box|
        <<-JS
            $('#{check_box[:id]}').observe('click', function() {
              var check_box_name = $('#{check_box[:id]}').name
              var codes = new Array();

              $$('input[type="checkbox"][name="' + check_box_name + '"]').each(function (elem) {
                if (elem.checked) {
                  code_value = $(elem.id + '_code').value;
                  if (code_value.length > 0) {
                    codes.push(code_value)
                  }
                }
              })
              $('#{id}').writeAttribute('value', codes.join(","))
            });
        JS
      end.join
    end
  end

  def drop_down_code_js(options, id, hidden_field)
    @template.on_loaded_or_eval do
      script = "$('#{id}').observe('change', function() {\n"
      options.each do |option|
        script << "  if (this.value == '#{option[:value]}') { "
        script << "$('#{hidden_field}').writeAttribute('value', '#{option[:code]}') }\n"
      end
      script << "});"
      script
    end
  end

  def rb_export_js(radio_buttons, id)
    @template.on_loaded_or_eval do
      radio_buttons.collect do |radio_button|
        <<-JS
        $('#{radio_button[:id]}').observe('click', function() {
        $('#{id}').writeAttribute('value', '#{radio_button[:export_conversion_value_id]}') });
        JS
      end.join
    end
  end

  def dd_export_js(option_elements, hidden_conversion_field, id)
    @template.on_loaded_or_eval do
      script = "$('#{id}').observe('change', function() {\n"
      option_elements.each do |option_element|
        script << "  if (this.value == '#{option_element[:value]}') { "
        script << "$('#{hidden_conversion_field}').writeAttribute('value', '#{option_element[:export_conversion_value_id]}') }\n"
      end
      script << "});"
      script
    end
  end

  def export_conversion_value_id(event, question)
    answer = event.answers.find_by_question_id(question.id)
    answer.export_conversion_value_id unless answer.nil?
  end

  #### encapsulate some common form builder patterns ####
  def core_text(name, grid_pos, options={})
    @template.core_element(name, self, grid_pos) do
      @template.concat label(name)
      @template.concat core_text_field(name, options, event)
    end
  end

  def code_field(field_name, code_name, grid_pos, options={})
    @template.core_element(field_name, self, grid_pos) do
      @template.concat label(field_name)
      @template.concat dropdown_code_field(field_name, code_name, options, {}, event)
    end
  end

  def remove_check_box(grid_pos="horiz")
    @template.haml_tag(:span, :class => grid_pos) do
      @template.concat label(:_destroy)
      @template.concat check_box(:_destroy)
    end
  end

  def diagnostic_type_selector(options={})
    render_type_selector('diagnostic_types', options)
  end

  def epi_type_selector(options={})
    render_type_selector('epi_types', options)
  end

  def agency_type_selector(options={})
    render_type_selector('agency_types', options)
  end

  def exposed_type_selector(options={})
    render_type_selector('exposed_types', options)
  end

  def render_type_selector(types, options={})
    @template.render :partial => 'events/place_types', :locals => { :f => self, :types => types, :options => options }
  end

  def event
    @template.instance_eval { @event }
  end

  def disease
    event.try(:disease_event).try(:disease)
  end

  def new_record?
    @object.new_record?
  end

  private

  # To avoid stubbing associations everywhere, we'll just instantiate a
  # new instance of the correct type if the assocation is blank
  def fields_for_with_nested_attributes(association_name, args, block)
    unless args.first.respond_to?(:new_record?)
      associated_object = @object.send(association_name)
      if associated_object.blank?
        reflection = @object.class.reflections[association_name.to_sym]
        if reflection.collection?
          associated_object = @object.send(association_name).build
        else
          associated_object = @object.send("build_#{association_name}")
        end
        args.unshift associated_object
      end
    end
    super
  end

  class CorePath < Array

    class << self
      def [](base)
        new base
      end
    end

    def to_s
      bracketed
    end

    def bracketed
      slice(1..-1).inject(first) do |memo, s|
        memo += "[#{s}]"
      end
    end

    def underscore
      join('_')
    end

    def initialize(base)
      self << base.gsub(/\[.*$/, '')
      base.scan(/\[([^\[|.]*)\]/).flatten.each { |s| self << s }
    end

  end


end

