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

require 'csv'
require 'ostruct'

module EventsHelper
  
  def core_element(attribute, form_builder, css_class, &block)
    concat_core_field(:edit, :before, attribute, form_builder, block)
    concat("<span class='#{css_class}'>", block.binding)
    yield
    render_core_field_help_text(attribute, form_builder, block)
    concat("</span>", block.binding)
    concat_core_field(:edit, :after, attribute, form_builder, block)
  end

  def core_element_show(attribute, form_builder, css_class, &block)
    concat_core_field(:show, :before, attribute, form_builder, block)
    concat("<span class='#{css_class}'>", block.binding)
    yield
    render_core_field_help_text(attribute, form_builder, block)
    concat("&nbsp;</span>", block.binding) # The &nbsp; is there to help resolve wrapping issues
    concat_core_field(:show, :after, attribute, form_builder, block)
  end
  
  def core_element_print(attribute, form_builder, css_class, &block)
    concat_core_field(:print, :before, attribute, form_builder, block)
    concat("<span class='#{css_class}'>", block.binding)
    yield
    concat("&nbsp;</span>", block.binding) # The &nbsp; is there to help resolve wrapping issues
    concat_core_field(:print, :after, attribute, form_builder, block)
  end
  
  def render_investigator_view(view, f, form=nil)
    return "" if view.nil?
    result = ""
    
    form_elements_cache = form.nil? ? FormElementCache.new(view) : form.form_element_cache
    
    form_elements_cache.children(view).each do |element|
      result << render_investigator_element(form_elements_cache, element, f)
    end
    
    result
  end
  
  # Debt? Some duplication here of render_investigator_view
  def show_investigator_view(view, form=nil, f = nil)
    return "" if view.nil?
    result = ""
    
    form_elements_cache = form.nil? ? FormElementCache.new(view) : form.form_element_cache
    
    form_elements_cache.children(view).each do |element|
      result << show_investigator_element(form_elements_cache, element, f)
    end
    
    result
  end
  
  def print_investigator_view(view, form=nil, f = nil)
    return "" if view.nil?
    result = ""
    
    form_elements_cache = form.nil? ? FormElementCache.new(view) : form.form_element_cache
    
    form_elements_cache.children(view).each do |element|
      result << print_investigator_element(form_elements_cache, element, f)
    end
    
    result
  end
  
  def new_or_existing?(model)
    model.new_record? ? 'new' : 'existing'
  end

  def event_prefix_for_multi_models(new_or_existing, attribute_name, namespace=nil)
    prefix = @event.class.to_s.underscore
    prefix << "[#{namespace}]" if namespace
    prefix << "[#{new_or_existing}#{attribute_name}]"
    prefix
  end

  def add_lab_link(name, event)
    url = event.is_a?(MorbidityEvent) ? lab_form_new_cmr_path : lab_form_new_contact_event_path
    link_to_remote(name, :update => "new_lab_holder", :position => :before, :url => url, :method => :get)
  end

  def add_lab_result_link(name, event, prefix, lab_id)
    url = event.is_a?(MorbidityEvent) ? lab_result_form_new_cmr_path(:prefix => prefix) : lab_result_form_new_contact_event_path(:prefix => prefix)
    link_to_remote(name, :update => "new_lab_result_holder_#{lab_id}", :position => :before, :url => url, :method => :get)
  end

  def add_hospital_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "hospitals", :partial => 'events/hospital' , :object => Participation.new_hospital_participation
    end
  end

  def add_diagnostic_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "diagnostics", :partial => 'events/diagnostic' , :object => Participation.new_diagnostic_participation
    end
  end

  def add_treatment_link(name, event)
    url = event.is_a?(MorbidityEvent) ? treatment_form_new_cmr_path : treatment_form_new_contact_event_path
    link_to_remote(name, :update => "new_treatment_holder", :position => :before, :url => url, :method => :get)
  end

  def add_contact_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "contacts", :partial => 'events/contact' , :object => Participation.new_contact_participation
    end
  end

  def add_place_exposure_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :place_exposures, :partial => 'events/editable_place_exposure', :object => Participation.new_exposure_participation
    end
  end

  def add_clinician_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "clinicians", :partial => 'events/clinician' , :object => Participation.new_clinician_participation
    end
  end

  def add_reporting_agency_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, "reporting_agencies", :partial => 'events/reporting_agency' , :object => Participation.new_reporting_agency_participation
    end
  end

  def basic_morbidity_event_controls(event, with_show=true, with_export_options=false)
    can_update = User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    controls = ""
    controls << (link_to_function('Show', "send_url_with_tab_index('#{cmr_path(event)}')") << " | ") if with_show
    controls << (link_to_function('Edit', "send_url_with_tab_index('#{edit_cmr_path(event)}')") << " | ") if can_update
    controls << link_to('Print', formatted_cmr_path(event, "print") , :target => "_blank") << " ("
    controls << link_to('With Notes', formatted_cmr_path(event, "print", :note => "1") , :target => "_blank") << ") | "
    controls << (link_to('Delete', soft_delete_cmr_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete') << " | ")  if can_update && event.deleted_at.nil?
    if with_export_options
      controls << link_to_function('Export to CSV', nil) do |page|
        page[:export_options].visual_effect :slide_down
      end
    else
      controls << link_to('Export to CSV', cmr_path(event) + '.csv')
    end
    controls << ' | ' +  link_to('Create New Patient Event', {:controller => 'morbidity_events', :action => 'create', :return => 'true', :from_patient => event.patient.primary_entity.id}, {:method => :post}) if User.current_user.is_entitled_to?(:create_event)

    controls
  end

  def basic_contact_event_controls(event, with_show=true)
    can_update =  User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    controls = ""
    controls << link_to_function('Show', "send_url_with_tab_index('#{contact_event_path(event)}')") if with_show
    
    if can_update
      controls <<  " | "  if with_show
      controls << link_to_function('Edit', "send_url_with_tab_index('#{edit_contact_event_path(event)}')")
      if event.deleted_at.nil?
        controls <<  " | "
        controls << link_to('Delete', soft_delete_contact_event_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete')
      end
    end

    controls
  end

  def basic_place_event_controls(event, with_show=true)
    can_update = User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    controls = ""
    controls << link_to_function('Show', "send_url_with_tab_index('#{place_event_path(event)}')") if with_show
    
    if can_update
      controls <<  " | "  if with_show
      controls << link_to_function('Edit', "send_url_with_tab_index('#{edit_place_event_path(event)}')")
      if event.deleted_at.nil?
        controls <<  " | "
        controls << link_to('Delete', soft_delete_place_event_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete')
      end
    end
     
    controls
  end

  def state_controls(event)
    current_state = event.event_status
    return "" if ["CLOSED", "NEW"].include? current_state

    allowed_transitions = event.current_state.renderable_transitions do |transition_state|
      j_id = event.primary_jurisdiction.entity_id
      User.current_user.is_entitled_to_in?(transition_state.required_privilege, j_id)
    end

    controls = ""    
    allowed_transitions.each do |transition|
      case transition.state_code
      when "ACPTD-LHD", "RJCTD-LHD", "UI", "RJCTD-INV", "APP-LHD", "RO-MGR", "CLOSED", "RO-STATE"
        controls += radio_button_tag(transition.state_code,
                                     transition.state_code, 
                                     false, 
                                     :onclick => state_routing_js(:confirm => transition.state_code == 'RJCTD-LHD'))
        controls += transition.action_phrase 
      when "ASGD-INV"
        controls += "<br/>" unless controls.blank?
        event_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:route_event_to_investigator))
        controls += "<span>#{transition.action_phrase}:&nbsp;</span><br/>" 
        controls += select_tag("morbidity_event[event_queue_id]", "<option value=""></option>" + options_from_collection_for_select(event_queues, :id, :queue_name, event.event_queue_id), :id => 'morbidity_event__event_queue_id', :onchange => state_routing_js(:value => transition.state_code))
        controls += "<br/>"
        
        investigators = User.investigators_for_jurisdictions(event.jurisdiction.secondary_entity.place)
        controls += "<span>Assign to investigator:&nbsp;</span><br/>"
        controls += select_tag("morbidity_event[investigator_id]", "<option value=""></option>" + options_from_collection_for_select(investigators, :id, :best_name, event.investigator_id), :id => 'morbidity_event__investigator_id',:onchange => state_routing_js(:value => transition.state_code))
      when "IC"
        controls += submit_tag(transition.action_phrase, :id => "investigation_complete_btn", :onclick => state_routing_js(:value => transition.state_code))
      end
    end
  
    if controls.blank?
      controls += "<span style='color: gray'>No action permitted.</span>"
    else
      controls = %Q[
        #{form_tag(state_cmr_path(event))}
        #{hidden_field_tag("morbidity_event[event_status]", '')}
        #{controls} 
        </form>
      ]
    end
    controls
  end

  def jurisdiction_routing_control(event)
    controls = ""
    if User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, event.primary_jurisdiction.entity_id)
      
      controls += link_to_function('Route to Local Health Depts.', nil) do |page|
        page["routing_controls_#{event.id}"].visual_effect :blind_down
      end
      controls += "<div id='routing_controls_#{event.id}' style='display: none; position: absolute; z-index: 1000'>"
      controls += "<div style='background-color: #fff; border: solid 2px; padding: 15px; border-color: #000'>"
      jurisdictions = Place.jurisdictions
      controls += form_tag(jurisdiction_cmr_path(event))
      controls += "<span>Investigating jurisdiction: &nbsp;</span>" 
      controls += select_tag("jurisdiction_id", options_from_collection_for_select(jurisdictions, :entity_id, :short_name, event.primary_jurisdiction.entity_id))
      controls += "<br />Also grant access to:"

      controls += "<div style='width: 26em; border-left:1px solid #808080; border-top:1px solid #808080; border-bottom:1px solid #fff; border-right:1px solid #fff; overflow: auto;'>"
      controls += "<div style='background:#fff; overflow:auto;height: 9em;border-left:1px solid #404040;border-top:1px solid #404040;border-bottom:1px solid #d4d0c8;border-right:1px solid #d4d0c8;'>"

      jurisdictions.each do | jurisdiction |
        controls += "<label>" + check_box_tag("secondary_jurisdiction_ids[]", jurisdiction.entity_id, event.secondary_jurisdictions.include?(jurisdiction), :id => jurisdiction.short_name.tr(" ", "_")) + jurisdiction.short_name + "</label>"
      end

      controls += "</div></div>"
      controls += submit_tag("Route Event", :id => "route_event_btn", :style => "position: absolute; right: 15px; bottom: 5px")

      controls += "</form>"
      controls += link_to_function "Close", "Effect.BlindUp('routing_controls_#{event.id}')"
      controls += "</div>"
      controls += "</div>"
    else
      controls += "<span style='color: gray'>Routing disabled</span>"
    end
    controls
  end

  def state_routing_js(options = {})
    value = "'#{options[:value]}'" if options[:value]
    confirm = options[:confirm]
    js = []
    js << 'if(confirm("Are you sure?")) {' if confirm
    js << "$(this.form).getInputs('hidden', 'morbidity_event[event_status]').reduce().setValue(#{value || '$F(this)'});"
    js << 'this.form.submit();'
    js << '}' if confirm
    js.join(' ')
  end

  def new_cmr_link(text)
    link_to(text, new_cmr_path) if User.current_user.is_entitled_to?(:create_event)
  end

  def new_cmr_button(text)
    button_to_function(text, "location.href = '#{new_cmr_path}'") if User.current_user.is_entitled_to?(:create_event)
  end

  # Debt: Name methods could be dried up. Waiting for feedback on soft-delete UI changes.
  def patient_name(event, &block)
    return if event.nil?
    
    if event.deleted_at.nil?
      concat("<div class='patientname'>", block.binding)
    else
      concat("<div class='patientname-inactive'>", block.binding)
    end
    
    yield
    concat("</div>", block.binding)
  end
  
  def contact_name(event, &block)
    return if event.nil?
    
    if event.deleted_at.nil?
      concat("<div class='contactname'>", block.binding)
    else
      concat("<div class='contactname-inactive'>", block.binding)
    end
    
    yield
    concat("</div>", block.binding)
  end
  
  def place_name(event, &block)
    return if event.nil?
    
    if event.deleted_at.nil?
      concat("<div class='placename'>", block.binding)
    else
      concat("<div class='placename-inactive'>", block.binding)
    end
    
    yield
    concat("</div>", block.binding)
  end
   

  private
  
  def concat_core_field(mode, before_or_after, attribute, form_builder, block)
    return if  (@event.nil? || @event.form_references.nil?)
    # concat("#{form_builder.object_name}[#{attribute}]", block.binding)
    if (@event.attributes["type"] != "MorbidityEvent" || @can_investigate)
      @event.form_references.each do |form_reference|
        core_path = form_builder.options[:core_path] || form_builder.object_name
        configs = form_reference.form.form_element_cache.all_cached_field_configs_by_core_path("#{core_path}[#{attribute}]")
        configs.each do |config|
          element = before_or_after == :before ? element = form_reference.form.form_element_cache.children(config).first : form_reference.form.form_element_cache.children(config)[1]
          
          case mode
          when :edit
            concat(render_investigator_view(element, @event_form, form_reference.form), block.binding)
          when :show
            concat(show_investigator_view(element, form_reference.form, @event_form), block.binding)
          when :print
            concat(print_investigator_view(element, form_reference.form, @event_form), block.binding)
          end
          
        end
      end
    end
  end
  
  def render_investigator_element(form_elements_cache, element, f)
    result = ""
   
    case element.class.name
   
    when "SectionElement"
      result << render_investigator_section(form_elements_cache, element, f)
    when "GroupElement"
      result << render_investigator_group(form_elements_cache, element, f)
    when "QuestionElement"
      result << render_investigator_question(form_elements_cache, element, f)
    when "FollowUpElement"
      result << render_investigator_follow_up(form_elements_cache, element, f)
    end
    
    result
  end
  
  # Show mode counterpart to #render_investigator_element
  def show_investigator_element(form_elements_cache, element, f)
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
  def print_investigator_element(form_elements_cache, element, f)
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
      section_id = "section_investigate_#{element.id}";
      hide_id = section_id + "_hide";
      show_id = section_id + "_show"
      result <<  "<fieldset class='form_section'>"
      result << "<legend>#{element.name} "
      
      unless element.help_text.blank?
        result << render_help_text(element) 
        result << "&nbsp;"
      end

      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
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
      return "Could not render section element (#{element.id})"
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
      return "Could not render group element (#{element.id})"
    end
  end

  def tooltip(html_id, options={:fadein => 500, :fadeout => 500})
    tool_tip_command = ["'#{html_id}'"]
    tool_tip_command << options.map{|k,v| [k.to_s.upcase, v]} if options
    "<a id=\"#{html_id}_hotspot\" href=\"#\" onmouseover=\"TagToTip(#{tool_tip_command.flatten.join(', ')})\" onmouseout=\"UnTip()\">#{yield}</a>"
  end  

  def render_help_text(element)
    if element.is_a?(QuestionElement)
      return if element.question.nil?
      help_text = element.question.help_text
    else
      return if element.help_text.blank?
      help_text = element.help_text
    end
    
    identifier = element.class.name.underscore[0..element.class.name.underscore.index("_")-1]
    
    result = tooltip("#{identifier}_help_text_#{element.id}") do
      image_tag('help.png', :border => 0)    
    end
    result << "<span id=\"#{identifier}_help_text_#{element.id}\" style=\"display: none;\">#{help_text}</span>"
  end

  def render_core_field_help_text(attribute, form_builder, block)
    if @event
      core_path = (form_builder.options[:core_path] || form_builder.object_name) + "[#{attribute}]"
      core_field = @event.class.exposed_attributes[core_path]
      help = render_help_text(core_field[:model]) if core_field
      concat(help, block.binding) if help
    end
  end

  def render_investigator_question(form_elements_cache, element, f)
    begin
      question = element.question
      question_style = question.style.blank? ? "vert" : question.style
      result = "<div id='question_investigate_#{element.id}' class='#{question_style}'>"
    
      @answer_object = @event.get_or_initialize_answer(question.id)
     
      result << error_messages_for(:answer_object)
      if (f.nil?)
        fields_for(@event) do |f|
          f.fields_for(:new_answers, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
            result << answer_template.dynamic_question(form_elements_cache, element, @event, "", {:id => "investigator_answer_#{element.id}"})
            result << render_help_text(element) unless question.help_text.blank?
          end
        end
      else
        prefix = @answer_object.new_record? ? "new_answers" : "answers"
        index = @answer_object.new_record? ? "" : @form_index += 1
        f.fields_for(prefix, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
          result << answer_template.dynamic_question(form_elements_cache, element, @event, index, {:id => "investigator_answer_#{element.id}"})
          result << render_help_text(element) unless question.help_text.blank?
        end
      end

      follow_up_group = element.process_condition(@answer_object, @event.id, form_elements_cache)
      
      unless follow_up_group.nil?
        result << "<div id='follow_up_investigate_#{element.id}'>"
        result << render_investigator_follow_up(form_elements_cache, follow_up_group, f)
        result << "</div>"
      else
        result << "<div id='follow_up_investigate_#{element.id}'></div>"
      end
    
      result << "</div>"
    
      result << "<br clear='all'/>" if question_style == "vert"
    
      return result
    rescue
      logger.warn($!.message)
      return "Could not render question element (#{element.id})"
    end
  end
  
  def render_investigator_follow_up(form_elements_cache, element, f)
    begin
      result = ""
    
      unless element.core_path.blank?
        result << render_investigator_core_follow_up(form_elements_cache, element, f) unless element.core_path.blank?
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
      return "Could not render follow up element (#{element.id})"
    end
  end
  
  def render_investigator_core_follow_up(form_elements_cache, element, f, ajax_render =false)
    begin
      result = ""    
      include_children = false
    
      unless (ajax_render)
        # Debt: Replace with shorter eval technique
        core_path_with_dots = element.core_path.sub("#{@event.class.name.underscore}[", "").gsub(/\]/, "").gsub(/\[/, ".")
        core_value = @event
        core_path_with_dots.split(".").each do |method|
          begin
            core_value = core_value.send(method)
          rescue
            break
          end
        end

        if (element.condition == core_value.to_s)
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
      return "Could not render core follow up element (#{element.id})"
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
      result <<  "<fieldset class='form_section'>"
      result << "<legend>#{element.name} "
      
      unless element.help_text.blank?
        result << render_help_text(element) 
        result << "&nbsp;"
      end
      
      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
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
      return "Could not render section element (#{element.id})"
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
      return "Could not render group element (#{element.id})"
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

      follow_up_group = element.process_condition({:response => answer.text_answer}, @event.id, form_elements_cache) unless answer.nil?
      
      unless follow_up_group.nil?
        result << "<div id='follow_up_investigate_#{element.id}'>"
        result << show_investigator_follow_up(form_elements_cache, follow_up_group, f)
        result << "</div>"
      end
      
      result << "<br clear='all'/>" if question_style == "vert"
      return result
    rescue
      logger.warn($!.message)
      return "Could not show question element (#{element.id})"
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
      return "Could not render follow up element (#{element.id})"
    end
  end
  
  # Show mode counterpart to #render_investigator_core_follow_up
  # 
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def show_investigator_core_follow_up(form_elements_cache, element, f, ajax_render =false)
    begin
      result = ""
    
      include_children = false
    
      unless (ajax_render)
        # Debt: Replace with shorter eval technique
        core_path_with_dots = element.core_path.sub("#{@event.class.name.underscore}[", "").gsub(/\]/, "").gsub(/\[/, ".")
        core_value = @event
        core_path_with_dots.split(".").each do |method|
          begin
            core_value = core_value.send(method)
          rescue
            break
          end
        end

        if (element.condition == core_value.to_s)
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
      return "Could not render core follow up element (#{element.id})"
    end
  end
  
  # Print mode counterpart to #render_investigator_section
  # 
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def  print_investigator_section(form_elements_cache, element, f)
    begin
      result = "<div class='print-section'>"
      result << "<br/>#{element.name}<br/>"
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
      return "Could not render group element (#{element.id})<br/>"
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

      follow_up_group = element.process_condition({:response => answer.text_answer}, @event.id, form_elements_cache) unless answer.nil?

      unless follow_up_group.nil?
        result << "<div id='follow_up_investigate_#{element.id}'>"
        result << print_investigator_follow_up(form_elements_cache, follow_up_group, f)
        result << "</div>"
      end

      result << "<br clear='all'/>" if question_style == "vert"
      return result
    rescue
      logger.warn($!.message)
      return "Could not show question element (#{element.id})<br/>"
    end
  end
  
  # Print mode counterpart to #render_investigator_follow_up
  # 
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_follow_up(form_elements_cache, element, f)
    begin
      result = ""
    
      unless element.core_path.blank?
        result << print_investigator_core_follow_up(form_elements_cache, element, f) unless element.core_path.blank?
        return result
      end
    
      questions = form_elements_cache.children(element)
    
      if questions.size > 0
        questions.each do |child|
          result << print_investigator_element(form_elements_cache, child, f)
        end
      end
    
      return result
    rescue
      logger.warn($!.message)
      return "Could not render follow up element (#{element.id})<br/>"
    end
  end
  
  # Print mode counterpart to #render_investigator_core_follow_up
  # 
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def print_investigator_core_follow_up(form_elements_cache, element, f)
    begin
      result = ""
    
      include_children = false
    
      # Debt: Replace with shorter eval technique
      core_path_with_dots = element.core_path.sub("#{@event.class.name.underscore}[", "").gsub(/\]/, "").gsub(/\[/, ".")
      core_value = @event
      core_path_with_dots.split(".").each do |method|
        begin
          core_value = core_value.send(method)
        rescue
          break
        end
      end
    
      if (element.condition == core_value.to_s)
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
      return "Could not render core follow up element (#{element.id})<br/>"
    end
  end

  # Renders events as csv. Optional block gives you the opportunity to
  # handle each event before it is converted to csv. This is handy for
  # looking up an actual event from a set of find_by_sql records.
  def render_events_csv(events, options={}, &proc)
    Export::Csv.export(events, options, &proc)
  end
  
end
