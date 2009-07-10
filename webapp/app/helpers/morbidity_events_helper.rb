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
    tabs << %w(demographic_tab Demographic)
    tabs << %w(clinical_tab Clinical)
    tabs << %w(lab_info_tab Laboratory)
    tabs << %w(contacts_tab Contacts)
    tabs << %w(encounters_tab Encounters)
    tabs << %w(epi_tab Epidemiological)
    tabs << %w(reporting_tab Reporting)
    tabs << %w(investigation_tab Investigation)
    tabs << %w(notes_tab Notes)
    tabs << %w(administrative_tab Administrative)
    tabs
  end

  def basic_morbidity_event_controls(event, from_index=false)
    # Originally the Edit, Delete, Add Task, and Add Attachment links were rendered only if the user had the right
    # privileges.  But that check was too expensive, so now they're always rendered.  In the (anticipated to be
    # rare) circumstances where someone has view but not update privs, clicking on the links will render a nice,
    # pretty 'go away' message.
    controls = ""
    controls << link_to('Show', cmr_path(event)) << " | " if from_index
    if from_index
      controls << link_to('Edit', edit_cmr_path(event))
    else
      controls << link_to_function('Edit', "send_url_with_tab_index('#{edit_cmr_path(event)}')")
    end
    if from_index
      controls << " | " << link_to('Print', cmr_path(event, :format => :print, :print_options => ['All']))
    else
      controls << " | " << link_to_function("Print", nil) do |page|
        page["printing_controls_#{event.id}"].visual_effect :appear, :duration => 0.0
      end
    end
    controls << " | " << link_to('Delete', soft_delete_cmr_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete') if event.deleted_at.nil?
    if !from_index
      controls << " | " << link_to('Add Task', new_event_task_path(event))
      controls << " | " << link_to('Add Attachment', new_event_attachment_path(event))
      controls << "<br />"
      controls << link_to_function('Export to CSV', nil) do |page|
        page[:export_options].visual_effect :appear
      end
      controls << ' | ' + link_to_function('Create a new event from this one') do |page|
        page[:copy_cmr_options].visual_effect :appear
      end
    # else
      # controls << link_to('Export to CSV', cmr_path(event) + '.csv')
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
end
