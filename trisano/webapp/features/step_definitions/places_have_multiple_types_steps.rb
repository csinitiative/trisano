When /^I enter a last name of (.+)$/ do |last_name|
  fill_in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name", :with => last_name
end

When /^I select School and Laboratory types for the diagnostic facility$/ do
  fill_in "morbidity_event_diagnostic_facilities_attributes_2_place_entity_attributes_place_attributes_name", :with => "DiagPlace"
  check "morbidity_event_diagnostic_facilities_attributes__2__place_entity_attributes__place_attributes_place_type_S"
  check "morbidity_event_diagnostic_facilities_attributes__2__place_entity_attributes__place_attributes_place_type_L"
end

When /^I select Pool and Daycare types for the place exposure$/ do
  fill_in "morbidity_event_place_child_events_attributes_5_interested_place_attributes_place_entity_attributes_place_attributes_name", :with => "EpiPlace"
  check "morbidity_event_place_child_events_attributes__5__interested_place_attributes__place_entity_attributes__place_attributes_place_type_P"
  check "morbidity_event_place_child_events_attributes__5__interested_place_attributes__place_entity_attributes__place_attributes_place_type_DC"
end

When /^I select Public and Other types for the reporting agency$/ do
  fill_in "morbidity_event_reporting_agency_attributes_place_entity_attributes_place_attributes_name", :with => "ReportingPlace"
  check "morbidity_event_reporting_agency_attributes__place_entity_attributes__place_attributes_place_type_PUB"
  check "morbidity_event_reporting_agency_attributes__place_entity_attributes__place_attributes_place_type_O"
end

Then /^I should be able to save the form and see my selections$/ do
  submit_form "new_morbidity_event"
  response.should contain("Laboratory and School")
  response.should contain("Pool and Daycare")
  response.should contain("Public and Other")
end
