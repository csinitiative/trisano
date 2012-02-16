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

module MorbidityEventsHelper
  extensible_helper

  def morbidity_event_tabs
    event_tabs_for :morbidity_event
  end

  def basic_morbidity_event_controls(event, view_mode)
    view_mode = :edit if ![:index, :edit, :show].include?(view_mode)

    can_update =  User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_view =  User.current_user.is_entitled_to_in?(:view_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_create =  User.current_user.is_entitled_to_in?(:create_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )

    controls = ""
    controls << link_to(t('show'), cmr_path(event), :class => "show_link") if ((view_mode == :index) && can_view)
    if can_update
      controls << " | " unless controls.blank?
      if (view_mode == :index)
        controls << link_to(t('edit'), edit_cmr_path(event), :class => "edit_link")
      elsif (view_mode == :edit)
        controls << link_to_function(t('show'), "send_url_with_tab_index('#{cmr_path(event)}')", :class => "show_link")
      else
        controls << link_to_function(t('edit'), "send_url_with_tab_index('#{edit_cmr_path(event)}')", :class => "edit_link")
      end
    end
    if can_view
      controls << " | " unless controls.blank?
      controls << link_to_function(t("print"), nil) do |page|
        page["printing_controls_#{event.id}"].visual_effect :appear, :duration => 0.0
      end
    end
    if event.deleted_at.nil? && can_update
      controls << " | " unless controls.blank?
      controls << link_to(t('delete'), soft_delete_cmr_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete')
    end
    if (view_mode != :index)
      if can_update
        controls << " | " unless controls.blank?
        if (view_mode == :edit)
          controls << link_to_remote(t('add_task'), :url => { :controller => 'event_tasks', :action => 'new', :event_id => event.id }, :method => :get )
        else
          controls << link_to(t('add_task'), new_event_task_path(event))
        end
        controls << " | " << link_to(t('add_attachment'), new_event_attachment_path(event))
      end
      if can_view
        controls << " | " unless controls.blank?
        controls << link_to_function(t('export_to_csv'), nil) do |page|
          page[:export_options].visual_effect :appear
        end
      end
      if can_create
        controls << " | " unless controls.blank?
        controls << link_to_function(t('create_new_event_from_this_one')) do |page|
          page[:copy_cmr_options].visual_effect :appear
        end
      end
    end
    controls
  end

  # grrr. sometimes a refresh leaves stuff checked. this makes sure
  # the right code/description options are displayed if that happens.
  def set_options_availability
    <<-JS
      <script type="text/javascript">
        document.observe('dom:loaded', function() {
          $$('#export_options_').each(function(field) {
            if (field.checked) {
              if (field.value == 'contacts')
                $('contact_code_field_options').show();
              else if (field.value == 'places')
                $('place_code_field_options').show();
              else if (field.value == 'labs')
                $('lab_code_field_options').show();
              else if (field.value == 'treatments')
                $('treatment_code_field_options').show();
            }
          });
        });
      </script>
    JS
  end

  def export_options_form(path)
    form_tag(path, :method => :post, :onsubmit => "Effect.Fade('export_options', { duration: 0.3 })", :id => 'export_options_form') do
      # When the export_options "window" is open we may be looking at a restricted view (in fact, that's all there is in the search screen)
      # based on an earlier GET.  We need to capture the previous GETs paramaters (which are also in the current GET) and hide them in this
      # form
      params.delete(:controller)
      params.delete(:commit)
      params.delete(:action)
      params.each_pair do |key, value|
        if value.is_a?(Array)
          value.each do |value_element|
            concat(hidden_field_tag("#{h(key)}[]", h(value_element)))
          end
        else
          concat(hidden_field_tag(h(key), h(value)))
        end
      end
      yield
    end
  end

  def new_cmr_search_results(results)
    results = NewCmrSearchResults.new(results, self)
    returning "" do |html|
      results.each do |result|
        html << new_cmr_search_result(result)
      end
    end
  end

  def new_cmr_search_result(result)
    tr_tag(:class => result.css_class, :id => result.css_id) do |tr|
      tr << td_tag(new_cmr_search_result_name(result))
      tr << td_tag(result.bdate)
      tr << td_tag(h(result.gender))
      tr << td_tag(result.event_type)
      tr << td_tag(h(result.jurisdiction))
      tr << td_tag(result.event_onset_date)
      tr << td_tag(h(result.disease_name))
      tr << td_tag(result.links)
      tr << td_tag(result.link_to_create_cmr)
    end
  end

  def new_cmr_search_result_name(result)
    result.name
  end

  def show_telephones(fields_or_form)
    show_country_code(fields_or_form) if Telephone.use?(:country_code)
    show_area_code(fields_or_form)    if Telephone.use?(:area_code)
    show_phone_number(fields_or_form)
    show_extension(fields_or_form)
  end

  def show_phone_field(field, fields_or_form)
    core_element_show field, fields_or_form, :horiz do
      concat(fields_or_form.label(field))
      concat(h(fields_or_form.object.configurable_format(field)))
    end
  end

  def show_country_code(fields_or_form)
    show_phone_field(:country_code, fields_or_form)
  end

  def show_area_code(fields_or_form)
    show_phone_field(:area_code, fields_or_form)
  end

  def show_phone_number(fields_or_form)
    show_phone_field(:phone_number, fields_or_form)
  end

  def show_extension(fields_or_form)
    show_phone_field(:extension, fields_or_form)
  end

  def edit_telephones(fields_or_form)
    edit_country_code(fields_or_form) if Telephone.use?(:country_code)
    edit_area_code(fields_or_form)    if Telephone.use?(:area_code)
    edit_phone_number(fields_or_form)
    edit_extension(fields_or_form)
  end

  def edit_phone_field(field, fields_or_form, options={})
    core_element(field, fields_or_form, :horiz) do
      concat(fields_or_form.label(field))
      concat(fields_or_form.core_text_field(field, options))
    end
  end

  def edit_country_code(fields_or_form)
    edit_phone_field(:country_code, fields_or_form, :size => 3)
  end

  def edit_area_code(fields_or_form)
    edit_phone_field(:area_code, fields_or_form, :size => 3)
  end

  def edit_phone_number(fields_or_form)
    edit_phone_field(:phone_number, fields_or_form, :size => 8)
  end

  def edit_extension(fields_or_form)
    edit_phone_field(:extension, fields_or_form, :size => 6)
  end

  def print_telephones(fields_or_form)
    print_country_code(fields_or_form) if Telephone.use?(:country_code)
    print_area_code(fields_or_form)    if Telephone.use?(:area_code)
    print_phone_number(fields_or_form)
    print_extension(fields_or_form)
  end

  def print_phone_field(field, fields_or_form)
    core_element_print(field, fields_or_form, :horiz) do
      concat(content_tag(:span, ct(field, :scope => [:activerecord, :attributes, :telephone]), :class => 'print-label'))
      concat("\n")
      concat(content_tag(:span, h(fields_or_form.object.configurable_format(field)), :class => 'print-value'))
    end
  end

  def print_country_code(fields_or_form)
    print_phone_field(:country_code, fields_or_form)
  end

  def print_area_code(fields_or_form)
    print_phone_field(:area_code, fields_or_form)
  end

  def print_phone_number(fields_or_form)
    print_phone_field(:phone_number, fields_or_form)
  end

  def print_extension(fields_or_form)
    print_phone_field(:extension, fields_or_form)
  end

end
