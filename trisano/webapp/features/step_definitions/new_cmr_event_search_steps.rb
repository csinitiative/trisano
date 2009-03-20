=begin
Given /^I am logged in as a super user$/ do
  ENV["TRISANO_UID"] = "utah" 
end

Given /^a (.+) event for last name (.+) with disease (.+) in jurisdiction (.+)$/ do |event_type, last_name, disease, jurisdiction|
  @m = create_basic_event(event_type, last_name, disease, jurisdiction)
end

Given /^a published disease form called (.+) for (.+) events with (.+)$/ do |form_name, event_type, disease|
  create_published_form(event_type, form_name, disease)
end

Given /^there is a contact named (.+)$/ do |last_name|
  @child = add_child_to_event(@m, last_name)
end

When /^I visit contacts show page$/ do
  visit contact_event_path(@child)
end  

Then /^I should see a link to promote event to a CMR$/ do
  response.should have_selector("a#event-type[href='#{event_type_contact_event_path(@m.contact_child_events.first)}']")
end

When /^I promote Jones to a morbidity event$/ do
  visit contact_event_path(@child)
  click_link "Promote to CMR"
end

Then /^I should be on the show morbidity event for Jones page$/ do
  path = cmr_path(@child)
  current_url.should =~ /#{path}/
end

Then /^the morbidity event should have disease forms for MA1 and CA1$/ do
  response.should have_selector("#investigation_form_list li", :content => "MA1")
  response.should have_selector("#investigation_form_list li", :content => "CA1")
end

Then /^the new morbidity event should show Smith as the parent$/ do
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='morbidity_parent_event']//*[contains(text(), 'Smith')]")
end

Then /^the parent CMR should show the child as an elevated contact$/ do
  visit cmr_path(@m)
  response.should have_xpath("//div[@id='contacts_tab']//div[@id='morbidity_child_events']//*[contains(text(), 'Jones')]")
end


=end
Given /^a simple (.+) event for last name (.+)$/ do |event_type, last_name|
  @m = create_basic_event(event_type, last_name)
end

Given /^I am logged in as a user without view or update privileges in Davis County$/ do
  log_in_as("investigator")
end

Given /^there are ([0-9]+) morbidity events for a single person with the last name (.+)$/ do | count, last_name |
  e = PersonEntity.create(:person_attributes => {:last_name => last_name})
  count.to_i.times { HumanEvent.new_event_from_patient(e).save }
end

When /^I click the "(.+)" link$/ do |link|
  # visit cmrs_path
  click_link link
end

When /^I search for "(.+)"$/ do |search_string|
  visit event_search_cmrs_path
  fill_in "Name", :with => search_string 
  click_button "Search"
end

Then /^I should see a search form$/ do
  response.should have_selector("form[method='get'][action='#{event_search_cmrs_path}']")
  field_labeled("Name").value.should be_nil
end

Then /^I should not see a link to enter a new CMR$/ do
  response.should_not have_selector("a[href='#{new_cmr_path}']")
end

Then /^I should see results for Jones and Joans$/ do
  response.should contain("Jones")
  response.should contain("Joans")
end

Then /^the search field should contain Jones$/ do
  field_labeled("Name").value.should == "Jones"
end

Then /^I should see results for both records$/ do
  response.should have_selector("table.list") do |table|
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Morbidity event")
    end
    table.should have_selector("tr") do |tr|
      tr.should contain("Jones")
      tr.should contain("Contact event")
    end
  end
end

Then /^the disease should show as 'private'$/ do
  response.should contain("Private")
  response.should_not contain("Mumps")
end

Then /^I should see two morbidity events under one name$/ do
  response.should have_selector("table.list tr:nth-child(2)") do |tr|
    tr.should contain("Jones")
    tr.should contain("Morbidity event")
  end
  response.should have_selector("tr:nth-child(3)") do |tr|
    tr.should_not contain("Jones")
    tr.should contain("Morbidity event")
  end
end
