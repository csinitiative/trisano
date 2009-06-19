Given /^I am logged in as a user with create and update privs in the Unassigned jurisdiction$/ do
  log_in_as("data_entry_tech")
end

Then /^I should see the staging area page$/ do
  current_url.should =~ /#{staged_messages_path}/
end

Given /^I am logged in as a user without create and update privs in the Unassigned jurisdiction$/ do
  log_in_as("state_manager")
end

Then /^I should not see the staging area link$/ do
  response.should_not have_selector("a[href='#{staged_messages_path}']")
end

When /^I visit the staging area page directly$/ do
  visit staged_messages_path
end

Then /^I should get a 403 response$/ do
  # Why can't I say: response.should be_forbidden
  # Or repsonse.code.should == :forbidden
  # Or, at the very least response.code.should == 403
  response.code.should == "403"
end

Given /^there are no matching entries$/ do
  # Do nothing
end

When /^I click '(.+)' for the staged message$/ do | link |
  click_link_within "#message_#{@staged_message.id}",  link
end

Then /^I should be sent to the search results page$/ do
  response.should contain("Event Search using staged message #{@staged_message.id}")
end

Then /^I should see the staged message$/ do
  response.should have_selector("#message_#{@staged_message.id}")
end

Then /^I should not see any matching results$/ do
  response.should_not have_selector("table#search_results")
end

When /^there is an event with a matching name but no birth date$/ do
  @event = Factory.build(:morbidity_event)
  @event.interested_party.person_entity.person.last_name = @staged_message.patient.patient_name.split(',').first
  @event.save
end

Then /^I should see matching results$/ do
  response.should have_selector("table#search_results")
end

Then /^there is an event with a matching name and birth date$/ do
  @event = Factory.build(:morbidity_event)
  @event.interested_party.person_entity.person.last_name = @staged_message.patient.patient_name.split(',').first
  @event.interested_party.person_entity.person.birth_date = @staged_message.patient.birth_date
  @event.save
end

When /^I click the '(.+)' link of the found event$/ do |link|
  # JavaScript!!!
  # click_link_within "#event_#{@event.id}",  link
  
  submit_form "assign_#{@event.id}"
end

Then /^I should see a success message$/ do
  response.should contain('success') # As in 'Lab result has been successfully assigned
end

Then /^I should remain on the staged message show page$/ do
  path = staged_message_path(@staged_message)
  current_url.should =~ /#{path}/
end

When /^I visit the assigned-to event$/ do
  visit cmr_path(@event)
end
  
Then /^I should see the new lab result$/ do
  response.should contain(@staged_message.message_header.sending_facility)
  response.should contain(@staged_message.observation_request.test_performed)
  response.should contain(@staged_message.observation_request.tests.first.result)
  response.should contain(@staged_message.observation_request.collection_date)
  response.should contain(/#{@staged_message.observation_request.specimen_source}/i) 
  response.should contain(@staged_message.observation_request.tests.first.reference_range)
  response.should contain(@staged_message.observation_request.tests.first.observation_date)
end

