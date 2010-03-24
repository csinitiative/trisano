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

module MorbidityEventsHelper

  def morbidity_event_tabs
    tabs = []
    tabs << ['demographic_tab', t('demographic')]
    tabs << ['clinical_tab', t('clinical')]
    tabs << ['lab_info_tab', t('laboratory')]
    tabs << ['contacts_tab', t('contacts')]
    tabs << ['encounters_tab', t('encounters')]
    tabs << ['epi_tab', t('epi')]
    tabs << ['reporting_tab', t('reporting')]
    tabs << ['investigation_tab', t('investigation')]
    tabs << ['notes_tab', t('event_notes')]
    tabs << ['administrative_tab', t('administrative')]
    tabs
  end

  def basic_morbidity_event_controls(event, from_index=false)
    can_update =  User.current_user.is_entitled_to_in?(:update_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_view =  User.current_user.is_entitled_to_in?(:view_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )
    can_create =  User.current_user.is_entitled_to_in?(:create_event, event.all_jurisdictions.collect { | participation | participation.secondary_entity_id } )

    controls = ""
    controls << link_to(t('show'), cmr_path(event)) if from_index && can_view
    if can_update
      controls << " | " unless controls.blank?
      if from_index
        controls << link_to(t('edit'), edit_cmr_path(event))
      else
        controls << link_to_function(t('edit'), "send_url_with_tab_index('#{edit_cmr_path(event)}')")
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
    if !from_index
      if can_update
        controls << " | " unless controls.blank?
        controls << link_to(t('add_task'), new_event_task_path(event))
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
      tr << td_tag(result.name)
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
end
