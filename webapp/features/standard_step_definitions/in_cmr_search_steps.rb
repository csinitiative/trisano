Given /^an active clinician named "([^\"]*)"$/ do |name|
  @clinician = Factory.build(:clinician, :last_name => name)
  @clinician_entity = Factory.build(:person_entity)
  @clinician_entity.person = @clinician
  @clinician_entity.save!
end

Given /^a diagnostic facility named "([^\"]*)"$/ do |name|
  create_diagnostic_facility!(name)
end

When /^I search for a diagnostic facility named "([^\"]*)"$/ do |name|
  visit url_for({ :controller => :morbidity_events,
                  :action => :diagnostic_facilities_search,
                  :name => name })
end

Given /^a place exposure named "([^\"]*)"$/ do |name|
  create_place_exposure!(name)
end

When /^I search for a place exposure named "([^\"]*)"$/ do |name|
  visit url_for({ :controller => :morbidity_events,
                  :action => :auto_complete_for_places_search,
                  :place_name => name })
end

Given /^a reporting agency named "([^\"]*)"$/ do |name|
  create_reporting_agency!(name)
end

When /^I search for a reporting agency named "([^\"]*)"$/ do |name|
  visit url_for({ :controller => :morbidity_events,
                  :action => :auto_complete_for_reporting_agency_search,
                  :place_name => name })
end

Given /^a contact named "([^\"]*)"$/ do |name|
  create_contact!(name)
end

When /^I search for a contact named "([^\"]*)"$/ do |arg1|
  visit url_for({ :controller => :events,
                  :action => :contacts_search,
                  :contact_search_name => name })
end

