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
