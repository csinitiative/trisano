Given /^I am logged in as a user with create and update privs in the Unassigned jurisdiction$/ do
  log_in_as("data_entry_tech")
end

Then /^I should see the staging area page$/ do
  path = staged_messages_path
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

When /^I click (.+) for the staged message$/ do | link |
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

