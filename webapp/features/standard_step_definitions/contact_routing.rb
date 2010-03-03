When /^I create an event with a contact$/ do
  fill_in "morbidity_event_interested_party_attributes_person_entity_attributes_person_attributes_last_name", :with => "Jones"
  fill_in "morbidity_event_contact_child_events_attributes_0_interested_party_attributes_person_entity_attributes_person_attributes_last_name", :with => "Smith"
  submit_form "new_morbidity_event"
end

When /^I route it to (.+)$/ do |jurisdiction|
    select(jurisdiction, :from => "jurisdiction_id") 
    click_button("route_event_btn")
end

