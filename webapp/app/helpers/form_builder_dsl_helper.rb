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

module FormBuilderDslHelper

  def concat_core_field(mode, before_or_after, attribute, form_builder)
    return if  (@event.nil? || @event.form_references.nil?)
    @event.form_references.each do |form_reference|
      
      current_core_path = (form_builder.core_path << attribute).to_s #valid core path
      concat(core_customization(form_reference, current_core_path, @event_form, before_or_after, mode, form_builder))

      if @event.type == "MorbidityEvent" || @event.type == "AssessmentEvent"
        alternate_forms_core_path_prefix = form_builder.core_path.clone
        # replace root of core path with previous event type
        alternate_forms_core_path_prefix[0] = "morbidity_and_assessment_event"

        alternate_forms_core_path = (alternate_forms_core_path_prefix << attribute).to_s
        output = core_customization(form_reference, alternate_forms_core_path, @event_form, before_or_after, mode, form_builder)
        if output.present?
          # before we render this output, update the path to be usable on current form
          output.gsub!(alternate_forms_core_path, current_core_path)
          concat(output)
        end 
      end


      @event.event_type_transitions.each do |event_type_transition|


        historical_core_path_prefix = form_builder.core_path.clone
        # replace root of core path with previous event type
        historical_core_path_prefix[0] = event_type_transition.was.underscore

        historical_core_path = (historical_core_path_prefix << attribute).to_s

        output = core_customization(form_reference, historical_core_path, @event_form, before_or_after, mode, form_builder)
        if output.present?
          # before we render this output, update the path to be usable on current form
          output.gsub!(historical_core_path, current_core_path)
          concat(output)
        end 
      end #event_type_transitions
    end #form referneces
  end

  def core_customization(form_reference, core_path, current_form, before_or_after, mode, local_form_builder)
    customizations = form_reference.form.form_element_cache.all_cached_field_configs_by_core_path(core_path)

    customization = ""

    customizations.each do |config|
      element = before_or_after == :before ? element = form_reference.form.form_element_cache.children(config).first : form_reference.form.form_element_cache.children(config)[1]

      customization << case mode
      when :edit
        render_investigator_view(element, current_form, form_reference.form, local_form_builder)
      when :show
        show_investigator_view(element, form_reference.form, current_form)
      when :print
        print_investigator_view(element, form_reference.form, current_form)
      end
    end #configs

    return customization
  end

  def render_investigator_element(form_elements_cache, element, f, local_form_builder=nil)
    result = ""

    case element.class.name

    when "SectionElement"
      result << render_investigator_section(form_elements_cache, element, f)
    when "GroupElement"
      result << render_investigator_group(form_elements_cache, element, f)
    when "QuestionElement"
      result << render_investigator_question(form_elements_cache, element, f, local_form_builder)
    when "FollowUpElement"
      result << render_investigator_follow_up(form_elements_cache, element, f)
    end

    result
  end

  # Show mode counterpart to #render_investigator_element
  def show_investigator_element(form_elements_cache, element, f, local_form_builder=nil)
    result = ""

    case element.class.name

    when "SectionElement"
      result << show_investigator_section(form_elements_cache, element, f)
    when "GroupElement"
      result << show_investigator_group(form_elements_cache, element, f)
    when "QuestionElement"
      result << show_investigator_question(form_elements_cache, element, f)
    when "FollowUpElement"
      result << show_investigator_follow_up(form_elements_cache, element, f)
    end

    result
  end

  # Print mode counterpart to #render_investigator_element and #show_investigator_element
  def print_investigator_element(form_elements_cache, element, f, local_form_builder=nil)
    result = ""

    case element.class.name

    when "SectionElement"
      result << print_investigator_section(form_elements_cache, element, f)
    when "GroupElement"
      result << print_investigator_group(form_elements_cache, element, f)
    when "QuestionElement"
      result << print_investigator_question(form_elements_cache, element, f)
    when "FollowUpElement"
      result << print_investigator_follow_up(form_elements_cache, element, f)
    end

    result
  end

  def render_investigator_section(form_elements_cache, element, f)
    begin
      result = "<br/>"
      section_id = "section_investigate_#{h(element.id)}";
      hide_id = section_id + "_hide";
      show_id = section_id + "_show"
      result <<  "<fieldset class='form_section vert-break'>"
      result << "<legend>#{h(strip_tags(element.name))} "

      unless element.help_text.blank?
        result << render_help_text(element)
        result << "&nbsp;"
      end

      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[#{t('hide')}]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[#{t('show')}]</span>"
      result << "</legend>"
      result << "<div id='#{section_id}'>"
      result << "<i>#{element.description.gsub("\n", '<br/>')}</i><br/><br/>" unless element.description.blank?

      section_children = form_elements_cache.children(element)

      if section_children.size > 0
        section_children.each do |child|
          result << render_investigator_element(form_elements_cache, child, f)
        end
      end

      result << "</div></fieldset><br/>"

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:section_element), :id => element.id)
    end
  end

  def render_investigator_group(form_elements_cache, element, f)
    begin
      result = ""

      group_children = form_elements_cache.children(element)

      if group_children.size > 0
        group_children.each do |child|
          result << render_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:group_element), :id => element.id)
    end
  end

  def rendering_core_field(attribute, form_builder)
    cf = form_builder.core_field(attribute)
    if cf.rendered_on_event?(@event)
      concat_before_core_partials(cf.key, form_builder)
      yield(cf)
      concat_after_core_partials(cf.key, form_builder)
    end
  end

  def concat_before_core_partials(key, form_builder)
    before_core_partials[key].each do |before_partial|
      locals = before_partial[:locals] || {}
      before_partial[:locals] = {:f => form_builder}.merge(locals)
      concat(render(before_partial))
    end
  end

  def concat_after_core_partials(key, form_builder)
    after_core_partials[key].each do |after_partial|
      locals = after_partial[:locals] || {}
      after_partial[:locals] = { :f => form_builder }.merge(locals)
      concat(render(after_partial))
    end
  end

  def concat_block_or_replacement(core_field, form_builder, &block)
    replacement = core_replacement_partial[core_field.key]
    if replacement && core_field.replaced?(@event)
      locals = replacement[:locals] || {}
      replacement[:locals] = { :f => form_builder }.merge(locals)
      concat(render(replacement))
    else
      block.call
    end
  end

  def core_section(attribute, form_builder, css_class='form', &block)
    rendering_core_field(attribute, form_builder) do |cf|
      concat("<fieldset class='#{css_class}'>")
      concat("<legend>#{cf.name}</legend>")
      concat_block_or_replacement(cf, form_builder, &block)
      concat("</fieldset>")
    end
  end

  def core_tab(attribute, form_builder, &block)
    rendering_core_field(attribute, form_builder) do |cf|
      concat "<div id=\"#{attribute.to_s}\" class=\"tab\">"
      concat_block_or_replacement cf, form_builder, &block
      concat "<br clear=\"all\"/>"
      concat link_to_top
      concat "</div>"
    end
  end

  def core_element(attribute, form_builder, css_class, mode=:edit, &block)
    rendering_core_field(attribute, form_builder) do |cf|
      concat_core_field(mode, :before, attribute, form_builder)
      concat("<span class='#{css_class}'>")
      concat_block_or_replacement(cf, form_builder, &block)
      concat(render_core_field_help_text(attribute, form_builder, @event))
      concat("&nbsp;</span>")
      concat_core_field(mode, :after, attribute, form_builder)
    end
  end

  def core_element_show(attribute, form_builder, css_class, &block)
    core_element(attribute, form_builder, css_class, :show, &block)
  end

  def core_element_print(attribute, form_builder, css_class, &block)
    core_element(attribute, form_builder, css_class, :print, &block)
  end

  def investigator_view(mode, view, form, f, local_form_builder=nil)
    return "" if view.nil?
    result = ""
    
    # To simplify the calls create a method reference which we can invoke below
    # example modes include :render, :show, :print 
    method_ref = method(mode + "_investigator_element")

    form_elements_cache = form.nil? ? FormElementCache.new(view) : form.form_element_cache

    form_elements_cache.children(view).each do |element|
      if !element.core_path.nil? && form.event_type != @event.type.underscore
        historical_element = element.dup #must use dup instead of clone to get element.id
        historical_element.core_path.sub!(form.event_type, @event.type.underscore)
        result << method_ref.call(form_elements_cache, historical_element, f, local_form_builder)
      else
        result << method_ref.call(form_elements_cache, element, f, local_form_builder)
      end
    end

    result
  end

  def render_investigator_view(view, f, form=nil, local_form_builder=nil)
    investigator_view("render", view, form, f, local_form_builder)
  end


  def show_investigator_view(view, form=nil, f = nil)
    investigator_view("show", view, form, f)
  end

  def print_investigator_view(view, form=nil, f = nil)
    investigator_view("print", view, form, f)
  end

  def render_help_text(element)
    if element.is_a?(QuestionElement)
      return "" if element.question.nil?
      help_text = element.question.help_text
    else
      return "" if element.nil? || element.help_text.blank?
      help_text = element.help_text
    end

    identifier = element.class.name.underscore[0..element.class.name.underscore.index("_")-1]

    result = tooltip("#{identifier}_help_text_#{element.id}") do
      image_tag('help.png', :border => 0)
    end
    result << "<span id='#{h(identifier)}_help_text_#{h(element.id)}' style='display: none;'>#{simple_format(help_text)}</span>"
  end

  def render_core_field_help_text(attribute, form_builder, event)
    return "" unless event
    core_field = form_builder.core_field(attribute)
    core_field ? render_help_text(core_field) : ""
  end


  def render_investigator_question(form_elements_cache, element, f, local_form_builder=nil)
    question_element = element
    question = question_element.question
    question_style = question.style.blank? ? "vert" : question.style
    result = "<div id='question_investigate_#{h(question_element.id)}' class='#{h(question_style)}'>"

    answer_attributes = {:question_id => question.id, 
                         :event_id => @event.id}



    if !local_form_builder.nil? && local_form_builder.repeater_form?
      repeater_parent_record = local_form_builder.object.repeater_parent

      answer_attributes[:repeater_form_object_type] = repeater_parent_record.class.name

      # This must be nil for new records so we get blank templates
      answer_attributes[:repeater_form_object_id] = repeater_parent_record.try(:id)
    end

    @answer_object = @event.get_or_initialize_answer(answer_attributes)




    error_messages = error_messages_for(:answer_object, :header_message => "#{pluralize(@answer_object.errors.count, "error")} prohibited this from being saved")
    error_messages.gsub!("There are unanswered required questions.", "'#{question.question_text}' is a required question.")
    error_messages.insert(0, "<br/>") if error_messages.present?
    result << error_messages


    if @answer_object.new_record?
      if !local_form_builder.nil? && local_form_builder.repeater_form?
        prefix = "new_repeater_answer"
      else
        prefix = "new_answers"
      end
      index = ""
    else
      prefix = "answers"
      @form_index = 0 unless @form_index
      index = @form_index += 1
    end
    fields_for(@event) do |f|
      f.fields_for(prefix, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
        result << answer_template_dynamic_question(answer_template, form_elements_cache, question_element, index, question)
      end
    end

    follow_up_group = question_element.process_condition(@answer_object,
      @event.id,
      :form_elements_cache => form_elements_cache)

    unless follow_up_group.empty?
      result << "<div id='follow_up_investigate_#{h(question_element.id)}'>"
      follow_up_group.each do |follow_up|
        result << render_investigator_follow_up(form_elements_cache, follow_up, f)
      end
      result << "</div>"
    else
      result << "<div id='follow_up_investigate_#{h(question_element.id)}'></div>"
    end

    result << "</div>"

    return result
    #rescue
    #logger.warn("Formbuilder rendering: #{$!.message}")
    #return "Could not render question element (#{element.id})"
  end

  def answer_template_dynamic_question(answer_template, form_elements_cache, element, index, question)
    result = ""
    # We must start included answer_id because now questions can be repeated
    # causing duplicate IDs in the DOM.
    # However, there can only be one answer for a question or it's a new answer.
    answer_id = answer_template.object.id || "new_answer"
    result << answer_template.dynamic_question(form_elements_cache, element, @event, index, {:id => "investigator_answer_#{h(element.id)}_#{answer_id}"})
    result << render_help_text(element) unless question.help_text.blank?
    result
  end

  def render_investigator_follow_up(form_elements_cache, element, f)
    begin
      result = ""

      unless element.core_path.blank?
        result << render_investigator_core_follow_up(form_elements_cache, element, f)
        return result
      end

      questions = form_elements_cache.children(element)

      if questions.size > 0
        questions.each do |child|
          result << render_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      logger.error $!.backtrace.join("\n")
      return t(:could_not_render, :thing => t(:follow_up_element), :id => element.id)
    end
  end

  def remove_event_type_from_core_path(core_path, event_type)
    # sub event type with blank string, will leave ] at the begining
    # so [1..-1]
    core_path.sub(event_type,"")[1..-1]
  end

  def replace_square_brackets_with_dots(string)
    # example: morbidity_event[disease][disease_name]
    # remove all "]" chars  (example becomes morbidity_event[disease[disease_name)
    # replace all "]" chars with "." (example becomes morbidity_event.diesase.disaese_name)
    string.gsub(/\]/, "").gsub(/\[/, ".")
  end

  def core_path_with_dots(element)
    new_path = element.core_path.clone
    core_path_to_method_array(new_path, @event.class.name.underscore)
  end

  def core_path_to_method_array(path, event_type)
    # Debt: Replace with shorter eval technique
    path = remove_event_type_from_core_path(path, event_type) 
    path = replace_square_brackets_with_dots(path)
  end
 
  def process_core_path(options)

    object = options[:object]
    method_array = options[:method_array]

    method_array = method_array.split(".") if method_array.is_a?(String) and method_array.include?(".")

    core_value = object
    method_array.each do |method|
      if core_value.is_a?(Array)
        core_value = core_value.collect { |cf| cf.try(:send, method) } 
        core_value.delete_if { |value| value.nil? }
      else
        core_value = core_value.try(:send, method)
      end
    end
    
    core_value

  end

  def value_from_core_path(options)
    element = options[:element]
    slice = options[:path_slice]

    method_array = core_path_with_dots(element).split(".")

    process_core_path(:object => options[:event],
                      :method_array => method_array)
  end

  def render_investigator_core_follow_up(form_elements_cache, element, f, ajax_render =false)
    begin
      result = ""
      include_children = false

      unless (ajax_render)
        core_value = value_from_core_path(:event => @event, :element => element)

        if (element.condition_match?(core_value.to_s))
          include_children = true
        end
      end

      result << "<div id='follow_up_investigate_#{element.id}'>" unless ajax_render

      if (include_children || ajax_render)
        questions = form_elements_cache.children(element)
        if questions.size > 0
          questions.each do |child|
            result << render_investigator_element(form_elements_cache, child, f)
          end
        end
      end

      result << "</div>" unless ajax_render

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:core_follow_up_element), :id => element.id)
    end
  end

  # Show mode counterpart to #render_investigator_section
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def  show_investigator_section(form_elements_cache, element, f)
    begin
      result = "<br/>"
      section_id = "section_investigate_#{element.id}";
      hide_id = section_id + "_hide";
      show_id = section_id + "_show"
      result <<  "<fieldset class='form_section vert-break'>"
      result << "<legend>#{strip_tags(element.name)} "

      unless element.help_text.blank?
        result << render_help_text(element)
        result << "&nbsp;"
      end

      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[#{t('hide')}]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[#{t('show')}]</span>"
      result << "</legend>"
      result << "<div id='#{section_id}'>"
      result << "<i>#{element.description.gsub("\n", '<br/>')}</i><br/><br/>" unless element.description.blank?

      section_children = form_elements_cache.children(element)

      if section_children.size > 0
        section_children.each do |child|
          result << show_investigator_element(form_elements_cache, child, f)
        end
      end

      result << "</div></fieldset><br/>"

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:section_element), :id => element.id)
    end
  end

  # Show mode counterpart to #render_investigator_group
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def show_investigator_group(form_elements_cache, element, f)
    begin
      result = ""

      group_children = form_elements_cache.children(element)

      if group_children.size > 0
        group_children.each do |child|
          result << show_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:group_element), :id => element.id)
    end
  end

  # Show mode counterpart to #render_investigator_question
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def show_investigator_question(form_elements_cache, element, f)
    begin
      question = element.question
      question_style = question.style.blank? ? "vert" : question.style
      result = "<div id='question_investigate_#{element.id}' class='#{question_style}'>"
      result << "<label>#{question.question_text}&nbsp;"
      result << render_help_text(element) unless question.help_text.blank?
      result << "</label>"
      answer = form_elements_cache.answer(element, @event)
      result << answer.text_answer unless answer.nil?
      result << "</div>"

      unless answer.nil?
        follow_up_group = element.process_condition(
          {:response => answer.text_answer},
          @event.id,
          :form_elements_cache => form_elements_cache
        )

        unless follow_up_group.empty?
          result << "<div id='follow_up_investigate_#{element.id}'>"
          follow_up_group.each do |follow_up|
            result << show_investigator_follow_up(form_elements_cache, follow_up, f)
          end
          result << "</div>"
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:group_element), :id => element.id)
    end
  end

  # Show mode counterpart to #render_investigator_follow_up
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def show_investigator_follow_up(form_elements_cache, element, f)
    begin
      result = ""

      unless element.core_path.blank?
        result << show_investigator_core_follow_up(form_elements_cache, element, f) unless element.core_path.blank?
        return result
      end

      questions = form_elements_cache.children(element)

      if questions.size > 0
        questions.each do |child|
          result << show_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:follow_up_element), :id => element.id)
    end
  end

  # Show mode counterpart to render_investigator_core_follow_up
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def show_investigator_core_follow_up(form_elements_cache, element, f, ajax_render =false)
    begin
      result = ""

      include_children = false

      unless (ajax_render)
        # when the event has been promoted, attached forms will have
        # core follow ups with core_paths which do match the current element's core path
        #
        core_value = @event
        core_path_with_dots(element).split(".").each do |method|
          begin
            core_value = core_value.send(method)
          rescue
            break
          end
        end

        if (element.condition_match?(core_value.to_s))
          include_children = true
        end
      end

      result << "<div id='follow_up_investigate_#{element.id}'>" unless ajax_render

      if (include_children || ajax_render)
        questions = form_elements_cache.children(element)

        if questions.size > 0
          questions.each do |child|
            result << show_investigator_element(form_elements_cache, child, f)
          end
        end
      end

      result << "</div>" unless ajax_render

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:core_follow_up_element), :id => element.id)
    end
  end

  # Print mode counterpart to #render_investigator_section
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def  print_investigator_section(form_elements_cache, element, f)
    begin
      result = "<div class='print-section'>"
      result << "<br/>#{strip_tags(element.name)}<br/>"
      result << "<span class='print-instructions'>#{element.description.gsub("\n", '<br/>')}</span>" unless element.description.blank?
      result << "<hr/>"

      section_children = form_elements_cache.children(element)

      if section_children.size > 0
        section_children.each do |child|
          result << print_investigator_element(form_elements_cache, child, f)
        end
      end

      result << "</div>"

      return result
    rescue
      logger.warn($!.message)
      return "Could not render section element (#{element.id})<br/>"
    end
  end

  # Print mode counterpart to #render_investigator_group
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_group(form_elements_cache, element, f)
    begin
      result = ""

      group_children = form_elements_cache.children(element)

      if group_children.size > 0
        group_children.each do |child|
          result << print_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:group_element), :id => element.id)
    end
  end

  # Print mode counterpart to #render_investigator_question
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_question(form_elements_cache, element, f)
    begin
      question = element.question
      question_style = question.style.blank? ? "vert" : question.style
      result = "<div id='question_investigate_#{element.id}' class='#{question_style}'>"
      result << "<span class='print-label'>#{question.question_text}:</span>&nbsp;"
      answer = form_elements_cache.answer(element, @event)
      result << "<span class='print-value'>#{answer.text_answer}</span>" unless answer.nil?
      result << "</div>"

      follow_up_group = element.process_condition({:response => answer.text_answer}, @event.id, :form_elements_cache => form_elements_cache) unless answer.nil?

      unless follow_up_group.nil?
        result << "<div id='follow_up_investigate_#{element.id}'>"
        result << print_investigator_follow_up(form_elements_cache, follow_up_group, f)
        result << "</div>"
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:question_element), :id => element.id)
    end
  end

  # Print mode counterpart to #render_investigator_follow_up
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_follow_up(form_elements_cache, element, f)
    begin
      result = ""

      return result if element.blank? or element.core_path.blank?

      result << print_investigator_core_follow_up(form_elements_cache, element, f)
      questions = form_elements_cache.children(element)

      if questions.size > 0
        questions.each do |child|
          result << print_investigator_element(form_elements_cache, child, f)
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:follow_up_element), :id => element.id) + "<br/>"
    end
  end

  # Print mode counterpart to #render_investigator_core_follow_up
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_core_follow_up(form_elements_cache, element, f)
    begin
      result = ""

      include_children = false

      core_value = @event
      core_path_with_dots(element).split(".").each do |method|
        begin
          core_value = core_value.send(method)
        rescue
          break
        end
      end

      if (element.condition_match?(core_value.to_s))
        questions = form_elements_cache.children(element)

        if questions.size > 0
          questions.each do |child|
            result << print_investigator_element(form_elements_cache, child, f)
          end
        end
      end

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :thing => t(:core_follow_up_element), :id => element.id) + "<br/>"
    end
  end

end
