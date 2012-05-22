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

def path_to(page_name)
  case page_name

  when /the homepage/i
    home_path

  when /the dashboard page/i
    home_path

  when /the access records page/i
    access_records_path

  when /the calendar page/i
    calendar_path(:year =>  Time.now.year, :month => Time.now.month)

  when /the admin dashboard page/i
    admin_path

  when /the analysis page/i
    analysis_path

  when /the jurisdictions page/i
    jurisdictions_path

  when /the show jurisdiction page/i
    jurisdiction_path

  when /the new CMR page/i
    new_cmr_path

  when /a new CMR/i
    new_cmr_path

  when /the show CMR page/i
    cmr_path @event

  when /view the CMR/i
    cmr_path @event

  when /the CMR show page/i
    cmr_path @event

  when /view the CMR/i
    cmr_path @event

  when /print the (.+) CMR data/i
    cmr_path(@event, :format => :print, 'print_options[]' => $1)

  when /the export CMR as csv page/i
    export_single_cmr_path @event, :format => 'csv'

  when /edit the CMR/i
    edit_cmr_path @event

  when /the event edit page/i
    edit_cmr_path @event

  when /show the CMR with record number "(\d*)"/
    cmr_path MorbidityEvent.find_by_record_number($1)

  when /the contact edit page/i
    edit_contact_event_path(@contact_event)

  when /the contact event edit page/i
    edit_contact_event_path(@contact_event)

  when /the place event edit page/i
    edit_place_event_path(@place_event)

  when /the encounter event edit page/i
    edit_encounter_event_path(@encounter)

  when /the encounter event show page/i
    encounter_event_path(@encounter)

  when /the contact show page/i
    contact_event_path(@contact_event || @event)

  when /the first CMR contact\'s edit page/i
    edit_contact_event_path(@event.contact_child_events.first)

  when /the first CMR contact\'s show page/i
    contact_event_path(@event.contact_child_events.first)

  when /the first CMR place\'s edit page/i
    edit_place_event_path(@event.place_child_events.first)

  when /the form builder page/i
    builder_path(@form)

  when /the add and remove forms page/i
    event_forms_path(@event)

  when /the "([^\"]*)" form details page/i
    form_path Form.templates.find_by_name($1)

  when /the "([^\"]*)" edit form page/i
    edit_form_path(Form.find_by_name($1))

  when /the form\'s edit questions page \(version ([\d]+)\)/i:
    @published_form = @form.published_versions.find_by_version($1)
    edit_form_questions_path @published_form

  when /the form\'s show questions page \(version ([\d]+)\)/i:
    @published_form = @form.published_versions.find_by_version($1)
    form_questions_path @published_form

  when /the investigator user edit page/i
    "/users/4/edit"

  when /the common test type index page/
    common_test_types_path

  when /the new common test type page/
    new_common_test_type_path

  when /(a|the) common test type show page/
    common_test_type_path(@common_test_type)

  when /edit the common test type/
    edit_common_test_type_path(@common_test_type)

  when /edit common test type "([^\"]*)"/
    edit_common_test_type_path CommonTestType.find_by_common_name($1)

  when /the common test type "([^\"]*)" page/
    common_test_type_path CommonTestType.find_by_common_name($1)

  when /manage the common test type\'s loinc codes/
    loinc_codes_common_test_type_path(@common_test_type)

  when /the admin dashboard/
    admin_path

  when /the places page/
    places_path

  when /the new place page/
    new_place_path

  when /the "([^"]*)" place show page/
    place_path(PlaceEntity.find(:first, :conditions => ["places.name = ?", $1], :include => :place))

  when /the place edit page/
    edit_place_path(@place_entity)

  when /the "([^\"]*)" core fields page/i
    disease = Disease.find_by_disease_name($1)
    disease_core_fields_path disease

  when /edit the "([^\"]*)" core field for the disease "([^\"]*)"/i
    core_field = CoreField.all.detect { |core_field| core_field.name == $1 }
    disease = Disease.find_by_disease_name($2)
    edit_disease_core_field_path(disease, core_field)

  when /edit the disease specific core field for the disease "([^\"]*)"/i
    disease = Disease.find_by_disease_name($1)
    edit_disease_core_field_path(disease, @core_field)

  when /the "([^\"]*)" core field for the disease "([^\"]*)"/i
    core_field = CoreField.all.detect { |core_field| core_field.name == $1 }
    disease = Disease.find_by_disease_name($2)
    disease_core_field_path(disease, core_field)

  when /the disease specific core field for the disease "([^\"]*)"/i
    disease = Disease.find_by_disease_name($1)
    disease_core_field_path(disease, @core_field)

  when /the disease specific treatments page for "([^\"]*)"/i
    disease = Disease.find_by_disease_name($1)
    disease_treatments_path(disease)

  when /edit the disease named "([^\"]*)"/
    edit_disease_path Disease.find_by_disease_name($1)

  when /edit the disease$/
    edit_disease_path(@disease)

  when /view the disease "([^\"]*)"/
    disease_path Disease.find_by_disease_name($1)

  when /the loinc code index page/
    loinc_codes_path

  when /the new loinc code page/
    new_loinc_code_path

  when /edit LOINC code "([^\"]*)"/
    edit_loinc_code_path LoincCode.find_by_loinc_code($1)

  when /edit the loinc code/
    edit_loinc_code_path @loinc_code

  when /the "([^"]*)" edit loinc code page/
    edit_loinc_code_path LoincCode.find_by_loinc_code($1)

  when /the loinc code show page/
    loinc_code_path @loinc_code

  when /the "([^"]*)" loinc code page/
    loinc_code_path LoincCode.find_by_loinc_code($1)

  when /the LOINC code "([^\"]*)" page/
    loinc_code_path LoincCode.find_by_loinc_code($1)

  when /the users index page/
    users_path

  when /view the default user/
    user_path User.find_by_user_name('default_user')

  when /the new user page/
    new_user_path

  when /edit the user/
    edit_user_path @user

  when /the "([^"]*)" organism page/
    organism_path Organism.find_by_organism_name($1)

  when /the "([^"]*)" edit organism page/
    edit_organism_path Organism.find_by_organism_name($1)

  when /the new organism page/
    new_organism_path

  when /the organisms index page/
    organisms_path

  when /the CDC export for the current week/i
    current_week_cdc_events_path

  when /the staged message search page/
    search_staged_messages_path

  when /the AVR groups page/
    avr_groups_path

  when /the new AVR group page/
    new_avr_group_path

  when /the AVR group show page/
    avr_group_path(@avr_group)

  when /the AVR group edit page/
    edit_avr_group_path(@avr_group)

  when /the roles page/i
    roles_path

  when /the edit "([^\"]*)" role page/i
    edit_role_path(Role.find_by_role_name($1))

  when /the CMR search page/i
    search_cmrs_path

  when /edit the person "(.+)"/i
    edit_person_path(Person.find_by_first_name_and_last_name(*$1.split(' ')).entity_id)

  when /the people search page/i
    people_path

  when /the places search page/i
    places_path

  when /the treatment admin page/i
    treatments_path

  when /the treatment show page/i
    treatment_path @treatment

  when /the manage e-mail addresses page/i
    email_addresses_path

  when /the edit task page/i
    edit_event_task_path @event, @event.tasks.first

  when /edit the core field/i
    edit_core_field_path @core_field

  when /view all core fields/i
    core_fields_path

  when /login/i
    login_path

  when /change password/i
    change_password_path

  when /the "([^\"]*)" core field$/i
    core_field_name = $1
    core_field = CoreField.all.detect { |core_field| core_field.name == core_field_name }
    edit_core_field_path(core_field)

  else
    ifnone = lambda { raise "Can't find mapping from \"#{page_name}\" to a path." }
    path_name = @@extension_path_names.find(ifnone) do |p|
      @match_data = Regexp.new(p[:page_name]).match(page_name)
    end
    instance_eval(&path_name[:path])
  end
end
