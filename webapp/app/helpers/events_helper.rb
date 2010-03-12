# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
  extensible_helper

  def hide
    return "[#{t 'hide'}]"
  end

  def show
    return "[#{t 'show'}]"
  end
  def ct(*args)
    return t('colon_after', :text => t(*args))
  end

  def core_element(attribute, form_builder, css_class, &block)
    concat_core_field(:edit, :before, attribute, form_builder)
    concat("<span class='#{css_class}'>")
    if renderer = core_element_renderers[form_builder.core_path[attribute].to_s]
      concat render(:partial => renderer[:partial], :locals => {:f => form_builder}.merge(renderer[:locals] || {}))
    else
      block.call
    end
    concat(render_core_field_help_text(attribute, form_builder, @event))
    concat("</span>")
    concat_core_field(:edit, :after, attribute, form_builder)
  end

  def core_element_show(attribute, form_builder, css_class, &block)
    concat_core_field(:show, :before, attribute, form_builder)
    concat("<span class='#{css_class}'>")
    if renderer = core_element_show_renderers[form_builder.core_path[attribute].to_s]
      concat render(:partial => renderer[:partial], :locals => {:f => form_builder}.merge(renderer[:locals] || {}))
    else
      block.call
    end
    concat(render_core_field_help_text(attribute, form_builder, @event))
    concat("&nbsp;</span>") # The &nbsp; is there to help resolve wrapping issues
    concat_core_field(:show, :after, attribute, form_builder)
  end

  def core_element_print(attribute, form_builder, css_class, &block)
    concat_core_field(:print, :before, attribute, form_builder)
    concat("<span class='#{css_class}'>")
    if renderer = core_element_show_renderers[form_builder.core_path[attribute].to_s]
      concat render(:partial => renderer[:partial], :locals => {:f => form_builder}.merge(renderer[:locals] || {}))
    else
      block.call
    end
    concat("&nbsp;</span>") # The &nbsp; is there to help resolve wrapping issues
    concat_core_field(:print, :after, attribute, form_builder)
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

  def add_record_link(form_builder, method, caption, options = {})
    link_to_function_options = {}
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:insert] ||= method

    link_to_function_options[:id] = options[:html_id] unless options[:html_id].nil?

    link_to_function(caption, link_to_function_options) do |page|
      form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD', :builder => ExtendedFormBuilder) do |f|
        html = h render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
        page << %{
          $('#{options[:insert]}').insert({
            bottom: '#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime())
          });
        }
      end
    end
  end

  def add_lab_link(name, prefix)
    event_type = /^.+_event/.match(prefix)[0]
    url = event_type == 'morbidity_event' ? lab_form_new_cmr_path(:prefix => prefix) : lab_form_new_contact_event_path(:prefix => prefix)
    url = case event_type
          when 'morbidity_event'
            lab_form_new_cmr_path(:prefix => prefix)
          when 'contact_event'
            lab_form_new_contact_event_path(:prefix => prefix)
          when 'encounter_event'
            lab_form_new_encounter_event_path(:prefix => prefix)
          end
    disease_field = "#{event_type}_disease_event_attributes_disease_id"  # Yeah, I don't like this any more than you do
    link_to_remote(name, :update => "new_lab_holder", :position => :before, :url => url, :method => :get, :with => "'disease_id=' + $F('#{disease_field}')")
  end

  def add_lab_result_link(name, prefix, lab_id)
    event_type = /^.+_event/.match(prefix)[0]
    url = case event_type
          when 'morbidity_event'
            lab_result_form_new_cmr_path(:prefix => prefix)
          when 'contact_event'
            lab_result_form_new_contact_event_path(:prefix => prefix)
          when 'encounter_event'
            lab_result_form_new_encounter_event_path(:prefix => prefix)
          end

    disease_field = "#{event_type}_disease_event_attributes_disease_id"  # Yeah, I don't like this any more than you do
    link_to_remote(name, :update => "new_lab_result_holder_#{lab_id}", :position => :before, :url => url, :method => :get, :with => "'disease_id=' + $F('#{disease_field}')")
  end

  def add_reporting_agency_link(name, form, options={})
    options = {:id => 'add_reporting_agency_link'}.merge(options)
    link_to_function name, nil, options do |page|
      # 'force new' is a hack to get the Add a Reporting Agency link to always render a form regardless of new mode, edit mode, validation failure, pre-event.
      page.update_reporting_agency('force new', form)
      page << "$('morbidity_event_reporting_agency_attributes_place_entity_attributes_place_attributes_name').value=$F('reporting_agency_search')"
    end
  end

  def update_reporting_agency(reporting_agency, form=nil)
    page.replace_html(:reporting_agency, :partial => 'events/reporting_agency' , :locals => {:f => form, :reporting_agency => reporting_agency})
    page.visual_effect :highlight, :reporting_agency, :duration => 3
  end

  def uniq_id
    Time.now.to_i
  end

  def warning_banner
    content_tag(:p, t(:out_of_jurisdiction_access, :link => link_to(t(:please_exit), home_path, :style => 'color: white; text-decoration: underline;')), :class => 'banner-warning')
  end

  def basic_contact_event_controls(event, from_index=false)
    can_update =  User.current_user.can_update?(event)
    can_view =  User.current_user.can_view?(event)

    controls = ""
    controls << link_to(t(:show), contact_event_path(event)) if from_index && can_view
    if can_update
      controls << " | " unless controls.blank?
      if from_index
        controls <<  link_to(t(:edit), edit_contact_event_path(event))
      else
        controls <<  link_to_function(t(:edit), "send_url_with_tab_index('#{edit_contact_event_path(event)}')")
      end
    end
    if can_view
      controls << " | " unless controls.blank?
      controls << link_to_function(t(:print), nil) do |page|
        page["printing_controls_#{event.id}"].visual_effect :appear, :duration => 0.0
      end
    end
    if event.deleted_at.nil? && can_update
      controls << " | " unless controls.blank?
      controls << link_to(t(:delete), soft_delete_contact_event_path(event), :method => :post, :confirm => t(:are_you_sure), :id => 'soft-delete')
    end
    if !from_index && can_update
      controls << " | " unless controls.blank?
      controls << link_to(t(:add_task), new_event_task_path(event))
      controls << " | " << link_to(t(:add_attachment), new_event_attachment_path(event))
      controls << " | " << link_to(t(:promote_to_cmr), event_type_contact_event_path(event), :method => :post, :confirm => t(:are_you_sure), :id => 'event-type')
    end

    controls
  end

  # places won't be shown in index view.  This code is only run from show mode, not edit.
  def basic_place_event_controls(event)
    can_update = User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    controls = ""

    if can_update
      controls << link_to_function(t(:edit), "send_url_with_tab_index('#{edit_place_event_path(event)}')")
      if event.deleted_at.nil?
        controls <<  " | " << link_to(t(:delete), soft_delete_place_event_path(event), :method => :post, :confirm => t(:are_you_sure), :id => 'soft-delete')
      end
    end

    controls
  end

  def action_controls(event)
    returning "" do |controls|
      event.allowed_transitions.each do |transition|
        case transition
        when :accept, :reject, :approve, :reopen, :close
          controls << radio_button_tag(
            h(transition.to_s),
            h(transition.to_s),
            false,
            :onclick => state_routing_js(:confirm => transition == :reject && event.assigned_to_lhd?))
          controls << t(transition)
        when :complete, :complete_and_close
          controls << submit_tag(
            t(transition),
            :id => "investigation_complete_btn",
            :type => "button",
            :onclick => state_routing_js(:value => transition.to_s))
        end
      end
    end
  end

  def assignment_controls(event)
    returning "" do |controls|
      event.allowed_transitions.each do |transition|
        case transition
        when :assign_to_queue
          event_queues = EventQueue.queues_for_jurisdictions(User.current_user.jurisdiction_ids_for_privilege(:route_event_to_investigator))
          controls << "<div>#{ct(:assign_to_queue)}&nbsp;"
          controls << select_tag("morbidity_event[event_queue_id]", "<option value=""></option>" + options_from_collection_for_select(event_queues, :id, :queue_name, event['event_queue_id']), :id => 'morbidity_event__event_queue_id', :onchange => state_routing_js(:value => transition.to_s), :style => "display: inline") + "</div>"
        when :assign_to_investigator
          investigators = User.investigators_for_jurisdictions(event.jurisdiction.place_entity.place)
          controls << "<div>#{ct(:assign_to_investigator)}&nbsp;"
          controls << select_tag("morbidity_event[investigator_id]", "<option value=""></option>" + options_from_collection_for_select(investigators, :id, :best_name, event['investigator_id']), :onchange => state_routing_js(:value => h(transition.to_s)), :id => 'morbidity_event__investigator_id', :style => "display: inline") + "</div>"
        end
      end
    end
  end

  def state_controls(event)
    return "" if event.new? or (event.is_a?(ContactEvent) && event.not_routed?) or event.closed? or event.rejected_by_lhd?

    routing_controls = assignment_controls(event)
    action_controls = action_controls(event)

    returning "" do |controls|
      if action_controls.blank? && routing_controls.blank?
        controls << "<span style='color: gray'>#{t(:insufficient_privs_transition)}</span>" if action_controls.blank?
      else
        controls << routing_form_tag(:state, event, :id => "state_change") do
          returning "" do |form|
            form << hidden_field_tag("morbidity_event[workflow_action]", '')
            form << "#{ct(:brief_note)} #{text_field_tag("morbidity_event[note]", '')}"
            form << "<br/> #{ct(:action_required)} #{action_controls} <br/>" unless action_controls.blank?
            form << routing_controls
          end
        end
      end
    end
  end

  def jurisdiction_routing_control(event)
    returning "" do |controls|
      if User.current_user.is_entitled_to_in?(:route_event_to_any_lhd, event.primary_jurisdiction.entity_id)
        controls << link_to_function(t('route_to_local'), nil) do |page|
          page["routing_controls_#{h(event.id)}"].visual_effect :appear, :duration => 0.5
        end
        controls << "<div id='routing_controls_#{h(event.id)}' style='display: none; position: relative'>"
        controls << "<div style='background-color: #fff; border: solid 2px; padding: 15px; border-color: #000'>"

        jurisdictions = Place.jurisdictions
        controls << routing_form_tag(:jurisdiction, event) do
          returning "" do |form|
            form << "<span>#{ct(:investigating_jurisdiction)} &nbsp;</span>"
            form << select_tag("jurisdiction_id", options_from_collection_for_select(jurisdictions, :entity_id, :short_name, event.primary_jurisdiction.entity_id)).untaint

            form << "<br />#{ct(:also_grant_access)}"
            form << "<div style='width: 26em; border-left:1px solid #808080; border-top:1px solid #808080; border-bottom:1px solid #fff; border-right:1px solid #fff; overflow: auto;'>"
            form << "<div style='background:#fff; overflow:auto;height: 9em;border-left:1px solid #404040;border-top:1px solid #404040;border-bottom:1px solid #d4d0c8;border-right:1px solid #d4d0c8;'>"
            jurisdictions.each do | jurisdiction |
              form << "<label>" + check_box_tag("secondary_jurisdiction_ids[]", h(jurisdiction.entity_id), event.secondary_jurisdictions.include?(jurisdiction), :id => h(jurisdiction.short_name.tr(" ", "_"))) + h(jurisdiction.short_name) + "</label>"
            end
            form << "</div></div>"

            form << "<div style='position: absolute; right: 15px'>#{ct(:brief_note)} #{text_field_tag("note", '')}</div><br/>"
            form << submit_tag(t(:route_event), :id => "route_event_btn", :style => "position: absolute; right: 15px; bottom: 5px")
          end
        end

        controls << link_to_function(t("close"), "Effect.Fade('routing_controls_#{h(event.id)}', { duration: 0.2 })")
        controls << "</div>"
        controls << "</div>"
      else
        controls << "<span style='color: gray'>#{t(:routing_disabled)}</span>"
      end
    end
  end

  def routing_form_tag(action, event, options={}, &block)
    path_meth = event.is_a?(MorbidityEvent) ? "#{action.to_s}_cmr_path" : "#{action.to_s}_contact_event_path"
    returning "" do |form|
      form << form_tag(send(path_meth, event), options)
      form << block.call if block_given?
      form << "</form>" if block_given?
    end
  end

  def state_routing_js(options = {})
    value = "'#{h(options[:value])}'" if options[:value]
    confirm = options[:confirm]
    js = []
    js << "if(confirm(\"#{t(:are_you_sure)}\")) {" if confirm
    js << "$(this.form).getInputs('hidden', 'morbidity_event[workflow_action]').reduce().setValue(#{value || '$F(this)'});"
    js << 'this.form.submit();'
    js << '}' if confirm
    js.join(' ')
  end

  def new_cmr_link(text)
    link_to(text, event_search_cmrs_path) if User.current_user.is_entitled_to?(:create_event)
  end

  def new_cmr_button(text)
    button_to_function(text, "location.href = '#{event_search_cmrs_path}'") if User.current_user.is_entitled_to?(:create_event)
  end

  def show_and_edit_event_links(event)
    return if event.new_record?
    show_and_edit_links[event.class.name][event]
  end

  def show_and_edit_links
    Hash[
         "MorbidityEvent", lambda { |event| links_to_show_and_edit(event, :show_cmr, :edit_cmr, :cmr_path, :edit_cmr_path) },
         "ContactEvent"  , lambda { |event| links_to_show_and_edit(event, :show_contact, :edit_contact) },
         "PlaceEvent"    , lambda { |event| links_to_show_and_edit(event, :show_place, :edit_place) },
         "EncounterEvent", lambda { |event| links_to_show_and_edit(event, :show_encounter, :edit_encounter) }
        ]
  end


  def links_to_show_and_edit(event, show_text, edit_text, *args)
    options =   args.extract_options!
    show_meth = args.first || "#{event.class.name.underscore}_path"
    edit_meth = args.last  || "edit_#{event.class.name.underscore}_path"
    user = User.current_user
    returning [] do |out|
      if user.can_view?(event)
        out << link_to(t(show_text, options), send(show_meth, event), {:id => "show-event-#{event.id}"})
      end
      if user.can_update?(event)
        out << link_to(t(edit_text, options), send(edit_meth, event), {:id => "edit-event-#{event.id}"})
      end
    end.join("&nbsp;|&nbsp;")
  end

  # Test type select list for Ajaxy add of new lab result
  #   No disease selected:                     blank, all test types
  #   Disease selected:                        blank, test types for disease, get more.

  # Test type select list for new and edit will be:
  #   new form (no disease selected):          blank, all test types.
  #   edit form, no disease selected, new lab: blank, all test types
  #   edit form, disease selected, new lab:    blank, test types for disease, get more.
  #   edit form, existing lab:                 blank, saved test type, get more.

  def test_type_options(event, disease, lab_result)
    no_more = false
    if event.nil?
      if disease.nil?
        # Ajax, no disease selected or Ajax, get all
        opts = CommonTestType.all(:order => "common_name ASC")
        no_more = true
      else
        # Ajax, disease selected
        opts = disease.common_test_types
        if opts.empty?
          opts = CommonTestType.all(:order => "common_name ASC")
          no_more = true
        end
      end
    else
      if event.new_record?
        # Page load, new form
        opts = CommonTestType.all(:order => "common_name ASC")
        no_more = true
      else
        if lab_result.new_record?
          if disease.nil?
            # Page load, edit form, new lab, no disease
            opts = CommonTestType.all(:order => "common_name ASC")
            no_more = true
          else
            # Page load, edit form, new lab, disease
            opts = disease.common_test_types
            if opts.empty?
              opts = CommonTestType.all(:order => "common_name ASC")
              no_more = true
            end
          end
        else
          # Page load, edit form, existing lab
          if lab_result.test_type
            opts = CommonTestType.find_all_by_common_name(lab_result.test_type.common_name)
          else
            opts = CommonTestType.all(:order => "common_name ASC")
            no_more = true
          end
        end
      end
    end
    unless no_more
      more = CommonTestType.new(:common_name => t(:more_choices))
      more.id = -1  # Otherwise, id is nil and the HTML OPTION value is the empty string, which conflicts with the blank value
      opts += [more]
    end
    opts
  end

  # Test type select list for Ajaxy add of new lab result
  #   No disease selected:                     blank, all test types
  #   Disease selected:                        blank, test types for disease, get more.

  # Test type select list for new and edit will be:
  #   new form (no disease selected):          blank, all test types.
  #   edit form, no disease selected, new lab: blank, all test types
  #   edit form, disease selected, new lab:    blank, test types for disease, get more.
  #   edit form, existing lab:                 blank, saved test type, get more.

  def organism_options(event, disease, lab_result)
    no_more = false
    if event.nil?
      if disease.nil?
        # Ajax, no disease selected or Ajax, get all
        opts = Organism.all(:order => "organism_name ASC")
        no_more = true
      else
        # Ajax, disease selected
        opts = disease.organisms
        if opts.empty?
          opts = Organism.all(:order => "organism_name ASC")
          no_more = true
        end
      end
    else
      if event.new_record?
        # Page load, new form
        opts = Organism.all(:order => "organism_name ASC")
        no_more = true
      else
        if lab_result.organism.blank?
          if disease.nil?
            # Page load, edit form, new lab, no disease
            opts = Organism.all(:order => "organism_name ASC")
            no_more = true
          else
            # Page load, edit form, new lab, disease
            opts = disease.organisms
            if opts.empty?
              opts = Organism.all(:order => "organism_name ASC")
              no_more = true
            end
          end
        else
          # Page load, edit form, existing lab
          opts = Organism.find_all_by_organism_name(lab_result.organism.organism_name)
        end
      end
    end
    unless no_more
      more = Organism.new(:organism_name => t(:more_choices))
      more.id = -1  # Otherwise, id is nil and the HTML OPTION value is the empty string, which conflicts with the blank value
      opts += [more]
    end
    opts
  end


  # Debt: Name methods could be dried up. Waiting for feedback on soft-delete UI changes.
  def event_div_class(event, &block)
    return if event.nil?

    if event.deleted_at.nil?
      concat("<div class='patientname'>")
    else
      concat("<div class='patientname-inactive'>")
    end

    yield
    concat("</div>")
  end

  def contact_name(event, &block)
    return if event.nil?

    if event.deleted_at.nil?
      concat("<div class='contactname'>")
    else
      concat("<div class='contactname-inactive'>")
    end

    yield
    concat("</div>")
  end

  def place_name(event, &block)
    return if event.nil?

    if event.deleted_at.nil?
      concat("<div class='placename'>")
    else
      concat("<div class='placename-inactive'>")
    end

    yield
    concat("</div>")
  end

  def setup_place_event_tree(event)
    event.build_interested_place unless event.interested_place
    event.interested_place.build_place_entity unless event.interested_place.place_entity
    event.interested_place.place_entity.build_place unless event.interested_place.place_entity.place
    event.build_address unless event.address
    event.interested_place.place_entity.telephones.build if event.interested_place.place_entity.telephones.empty?
    event.interested_place.place_entity.email_addresses.build if event.interested_place.place_entity.email_addresses.empty?
    event.build_participations_place unless event.participations_place

    event.build_disease_event unless event.disease_event
    event.notes.build if event.notes.empty?
    event.build_jurisdiction unless event.jurisdiction
    event
  end

  def setup_human_event_tree(event)
    # On Rails Edge as of 02-11-09 you can't use #first on one-to-many association proxies

    event.build_interested_party unless event.interested_party
    event.interested_party.build_person_entity unless event.interested_party.person_entity
    event.interested_party.person_entity.build_person unless event.interested_party.person_entity.person
    if event.is_a?(ContactEvent)
      event.build_participations_contact unless event.participations_contact
    end

    event.build_address unless event.address
    event.interested_party.person_entity.telephones.build if event.interested_party.person_entity.telephones.empty?
    event.interested_party.person_entity.email_addresses.build if event.interested_party.person_entity.email_addresses.empty?

    event.interested_party.treatments.build if event.interested_party.treatments.empty?
    event.interested_party.build_risk_factor unless event.interested_party.risk_factor

    event.build_disease_event unless event.disease_event

    event.hospitalization_facilities.build if event.hospitalization_facilities.empty?
    # Don't need to build place_entity and place here, since we can only assign from the UI
    event.hospitalization_facilities.each do |hospital|
      hospital.build_hospitals_participation unless hospital.hospitals_participation
    end

    event.clinicians.build if event.clinicians.empty?
    event.clinicians.each do |clinician|
      clinician.build_person_entity unless clinician.person_entity
      clinician.person_entity.build_person unless clinician.person_entity.person
      clinician.person_entity.telephones.build if clinician.person_entity.telephones.empty?
      # Don't need addresses for clinicians, but do need the special 'person_type'
      clinician.person_entity.person.person_type = 'clinician'
    end

    event.diagnostic_facilities.build if event.diagnostic_facilities.empty?
    event.diagnostic_facilities[0].build_place_entity unless event.diagnostic_facilities[0].place_entity
    event.diagnostic_facilities[0].place_entity.build_place unless event.diagnostic_facilities[0].place_entity.place
    # Don't need addresses or phones for diagnostic facilities

    event.labs.build if event.labs.empty?
    event.labs[0].build_place_entity unless event.labs[0].place_entity
    event.labs[0].place_entity.build_place unless event.labs[0].place_entity.place
    # Don't need addresses or phones for labs
    event.labs[0].lab_results.build if event.labs[0].lab_results.empty?

    if event.is_a?(MorbidityEvent)
      event.contact_child_events.build if event.contact_child_events.empty?
      # If in edit mode, there may be contacts without phones or dispositions, thus we loop to initialize them all
      event.contact_child_events.each do |contact|
        contact.build_participations_contact unless contact.participations_contact
        contact.build_interested_party unless contact.interested_party
        contact.interested_party.build_person_entity unless contact.interested_party.person_entity
        contact.interested_party.person_entity.build_person unless contact.interested_party.person_entity.person
        contact.interested_party.person_entity.telephones.build if contact.interested_party.person_entity.telephones.empty?
      end

      event.place_child_events.build if event.place_child_events.empty?
      # If in edit mode, there may be places without exposures, thus we loop to initialize them all
      event.place_child_events.each do |place|
        place.build_participations_place unless place.participations_place
        place.build_interested_place unless place.interested_place
        place.interested_place.build_place_entity unless place.interested_place.place_entity
        place.interested_place.place_entity.build_place unless place.interested_place.place_entity.place
        place.interested_place.place_entity.build_canonical_address unless place.interested_place.place_entity.canonical_address
      end

      event.encounter_child_events.build if event.encounter_child_events.empty?

      event.encounter_child_events.each do |encounter|
        encounter.build_participations_encounter unless encounter.participations_encounter
        encounter.build_interested_party unless encounter.interested_party
      end

      event.build_reporting_agency unless event.reporting_agency
      event.reporting_agency.build_place_entity unless event.reporting_agency.place_entity
      event.reporting_agency.place_entity.build_place unless event.reporting_agency.place_entity.place
      event.reporting_agency.place_entity.telephones.build if event.reporting_agency.place_entity.telephones.empty?

      event.build_reporter unless event.reporter
      event.reporter.build_person_entity unless event.reporter.person_entity
      event.reporter.person_entity.build_person unless event.reporter.person_entity.person
      event.reporter.person_entity.telephones.build if event.reporter.person_entity.telephones.empty?
    end
    event.notes.build if event.notes.empty?
    event.build_jurisdiction unless event.jurisdiction

    event
  end

  def blank_contact
    blank_contact = ContactEvent.new
    blank_contact.build_participations_contact
    blank_contact.build_interested_party
    blank_contact.interested_party.build_person_entity
    blank_contact.interested_party.person_entity.build_person
    blank_contact.interested_party.person_entity.telephones.build
    blank_contact
  end

  def original_patient_controls(event)
    disease = event.safe_call_chain(:parent_event, :disease_event, :disease, :disease_name)
    returning "" do |result|
      result << "<div>"
      result << ct(:parent_patient)
      result << "&nbsp;"
      result << link_to_parent(event)
      unless disease.blank?
        result << "&nbsp;|&nbsp;"
        result << "<span style='font-size: 12px; font-weight: light;'>#{h disease}</span>"
      end
      result << "</div>"
    end
  end

  def link_to_parent(event)
    parent = event.parent_event
    person = parent.party
    path = request.symbolized_path_parameters[:action] == 'edit' ? edit_cmr_path(parent) : cmr_path(parent)
    link_to(h(person.try(:full_name)), path)
  end

  def association_recorded?(association_collection)
    return nil unless association_collection.respond_to?(:each)
    (association_collection.empty? || association_collection.first.new_record?) ? false :true
  end

  def concat_core_field(mode, before_or_after, attribute, form_builder)
    return if  (@event.nil? || @event.form_references.nil?)
    @event.form_references.each do |form_reference|
      configs = form_reference.form.form_element_cache.all_cached_field_configs_by_core_path("#{form_builder.core_path[attribute].to_s}")
      configs.each do |config|
        element = before_or_after == :before ? element = form_reference.form.form_element_cache.children(config).first : form_reference.form.form_element_cache.children(config)[1]

        case mode
        when :edit
          concat(render_investigator_view(element, @event_form, form_reference.form))
        when :show
          concat(show_investigator_view(element, form_reference.form, @event_form))
        when :print
          concat(print_investigator_view(element, form_reference.form, @event_form))
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
      section_id = "section_investigate_#{h(element.id)}";
      hide_id = section_id + "_hide";
      show_id = section_id + "_show"
      result <<  "<fieldset class='form_section vert-break'>"
      result << "<legend>#{h(strip_tags(element.name))} "

      unless element.help_text.blank?
        result << render_help_text(element)
        result << "&nbsp;"
      end

      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
      result << "</legend>"
      result << "<div id='#{section_id}'>"
      result << "<i>#{sanitize(element.description.gsub("\n", '<br/>'), :tags => %w(br))}</i><br/><br/>" unless element.description.blank?

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
      return t(:could_not_render, :what => t(:section_element), :id => element.id)
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
      return t(:could_not_render, :what => t(:group_element), :id => element.id)
    end
  end

  def tooltip(html_id, options={:fadein => 500, :fadeout => 500, :width => -400})
    tool_tip_command = ["'#{html_id}'"]
    tool_tip_command << options.map{|k,v| [k.to_s.upcase, v]} if options
    "<a id=\"#{html_id}_hotspot\" href=\"#\" onmouseover=\"TagToTip(#{tool_tip_command.flatten.join(', ')})\" onmouseout=\"UnTip()\">#{yield}</a>"
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
    result << "<span id='#{h(identifier)}_help_text_#{h(element.id)}' style='display: none;'>#{simple_format(sanitize(help_text, :tags => %w(br)))}</span>"
  end

  def render_core_field_help_text(attribute, form_builder, event)
    return "" unless event
    core_path = form_builder.core_path[attribute].to_s
    core_field = CoreField.event_fields(event)[core_path]
    core_field ? render_help_text(core_field) : ""
  end

  def render_investigator_question(form_elements_cache, element, f)
    begin
      question = element.question
      question_style = question.style.blank? ? "vert" : question.style
      result = "<div id='question_investigate_#{h(element.id)}' class='#{h(question_style)}'>"

      @answer_object = @event.get_or_initialize_answer(question.id)

      result << error_messages_for(:answer_object)
      if (f.nil?)
        fields_for(@event) do |f|
          f.fields_for(:new_answers, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
            result << answer_template.dynamic_question(form_elements_cache, element, @event, "", {:id => "investigator_answer_#{h(element.id)}"})
            result << render_help_text(element) unless question.help_text.blank?
          end
        end
      else
        prefix = @answer_object.new_record? ? "new_answers" : "answers"
        index = @answer_object.new_record? ? "" : @form_index += 1
        f.fields_for(prefix, @answer_object, :builder => ExtendedFormBuilder) do |answer_template|
          result << answer_template.dynamic_question(form_elements_cache, element, @event, index, {:id => "investigator_answer_#{h(element.id)}"})
          result << render_help_text(element) unless question.help_text.blank?
        end
      end

      follow_up_group = element.process_condition(@answer_object, @event.id, form_elements_cache)

      unless follow_up_group.nil?
        result << "<div id='follow_up_investigate_#{h(element.id)}'>"
        result << render_investigator_follow_up(form_elements_cache, follow_up_group, f)
        result << "</div>"
      else
        result << "<div id='follow_up_investigate_#{h(element.id)}'></div>"
      end

      result << "</div>"

      return result
      #rescue
      #logger.warn("Formbuilder rendering: #{$!.message}")
      #return "Could not render question element (#{element.id})"
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
      return t(:could_not_render, :what => t(:follow_up_element), :id => element.id)
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
      return t(:could_not_render, :what => t(:core_follow_up_element), :id => element.id)
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

      result << "<span id='#{hide_id}' onClick=\"Element.hide('#{section_id}'); Element.hide('#{hide_id}'); Element.show('#{show_id}'); return false;\">[Hide]</span>"
      result << "<span id='#{show_id}' onClick=\"Element.show('#{section_id}'); Element.hide('#{show_id }'); Element.show('#{hide_id}'); return false;\" style='display: none;'>[Show]</span>"
      result << "</legend>"
      result << "<div id='#{section_id}'>"
      result << "<i>#{sanitize(element.description.gsub("\n", '<br/>'), :tags => %w(br))}</i><br/><br/>" unless element.description.blank?

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
      return t(:could_not_render, :what => t(:section_element), :id => element.id)
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
      return t(:could_not_render, :what => t(:group_element), :id => element.id)
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
      result << "<label>#{sanitize(question.question_text, :tags => %w(br))}&nbsp;"
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

      return result
    rescue
      logger.warn($!.message)
      return t(:could_not_render, :what => t(:group_element), :id => element.id)
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
      return t(:could_not_render, :what => t(:follow_up_element), :id => element.id)
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
      return t(:could_not_render, :what => t(:core_follow_up_element), :id => element.id)
    end
  end

  # Print mode counterpart to #render_investigator_section
  #
  # Debt? Dupliactes most of the render method. Consider consolidating.
  def  print_investigator_section(form_elements_cache, element, f)
    begin
      result = "<div class='print-section'>"
      result << "<br/>#{strip_tags(element.name)}<br/>"
      result << "<span class='print-instructions'>#{sanitize(element.description.gsub("\n", '<br/>'), :tags => %w(br))}</span>" unless element.description.blank?
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
      return t(:could_not_render, :what => t(:group_element), :id => element.id)
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
      result << "<span class='print-label'>#{sanitize(question.question_text, :tags => %w(br))}:</span>&nbsp;"
      answer = form_elements_cache.answer(element, @event)
      result << "<span class='print-value'>#{answer.text_answer}</span>" unless answer.nil?
      result << "</div>"

      follow_up_group = element.process_condition({:response => answer.text_answer}, @event.id, form_elements_cache) unless answer.nil?

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

  # Renders events as csv. Optional block gives you the opportunity to
  # handle each event before it is converted to csv. This is handy for
  # looking up an actual event from a set of find_by_sql records.
  def render_events_csv(events, options={})
    Export::Csv.export(events, options)
  end

  # wraps up remote function so it can be used in a prototype callback
  def remote_function_callback(options)
    <<-JS.gsub(/\s+/, ' ')
      function(event, selection) {
        #{remote_function(options)};
      }
    JS
  end

  def live_search_callback(options = {})
    options = {:attribute => 'name'}.merge(options)

    <<-JS.gsub(/\s+/, ' ')
      function(e, s) {
        var id = $(s).readAttribute('#{options[:attribute]}');
        new Ajax.Updater('#{h(options[:update])}', '#{url_for(options[:url])}', {
          asynchronous: true,
          evalScripts: true,
          parameters: {id: id},
          #{('insertion: ' + options[:insertion_point] + ',') unless options[:insertion_point] == 'None'}
          method: 'get'
        });
      }
    JS
  end
          # insertion: Insertion.Bottom

  def live_search(label, options = {})
    options[:search_field] ||= 'search_field'
    options[:alt]          ||= t(:searching)
    options[:indicator]    ||= options[:search_field] + '_spinner'
    options[:update]       ||= options[:search_field] + '_choices'
    options[:param_name]   ||= options[:select] if options[:select]
    options[:method]       ||= 'get'
    options[:url]          ||= {:controller => "morbidity_events", :action => "auto_complete_for_#{options[:search_field]}"}
    options[:results]      ||= options[:search_field] + '_results'
    options[:insertion_point] ||= 'Insertion.Bottom'
    options[:after_update_element_url] ||= {:controller => "morbidity_events", :action => options[:search_field] + '_selection', :event_type => options[:event_type]}
    options[:after_update_element]     ||= live_search_callback(:update => options[:results], :insertion_point => options[:insertion_point],
      :url => options[:after_update_element_url])
    <<-HTML
      #{auto_complete_stylesheet}
      #{content_tag(:label, label, :for => options[:search_field])}
      #{text_field_tag(options[:search_field], nil, :size => options[:field_width] || 25 )}
      #{image_tag('redbox_spinner.gif', :size => '16x16', :alt => options[:alt], :id => options[:indicator], :style => 'display: none;')}
      #{content_tag(:div, '', :class => 'auto_complete', :id => options[:update])}
      #{auto_complete_field(options[:search_field], extract_auto_complete_options(options))}
    HTML
  end

  def extract_auto_complete_options(options)
    allowed = [:select, :param_name, :update, :indicator, :method, :url, :after_update_element, :min_chars, :frequency]
    Hash[*options.select {|k, v| allowed.include?(k)}.flatten]
  end

  def alert_if_changed(form)
    javascript_tag do
      "var formWatcher = new FormWatch('#{get_form_id(form)}');"
    end
  end
end

