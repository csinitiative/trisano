Given /^I am logged in as a user with manage_staged_message privs$/ do
  log_in_as("surveillance_mgr")
end

Given /^I am logged in as a user with write_staged_message privs$/ do
  log_in_as("default_user")
end

Then /^I should see the staging area page$/ do
  current_url.should =~ /#{staged_messages_path}/
end

Given /^I am logged in as a user without staging area privs in the Unassigned jurisdiction$/ do
  log_in_as("state_manager")
end

Then /^I should not see the staging area link$/ do
  response.should_not have_selector("a[href='#{staged_messages_path}']")
end

When /^I visit the staging area page directly$/ do
  visit staged_messages_path
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

When /^there is a (.+) event with a matching name but no birth date$/ do |type|
  @event = Factory.build("#{type}_event".to_sym)
  @event.interested_party.person_entity.person.last_name = @staged_message.patient.patient_name.split(',').first
  @event.save!
end

Then /^I should see matching results$/ do
  response.should have_selector("table#search_results")
end

Given /^there is a (.+) event with a matching name and birth date$/ do |type|
  @event = Factory.build("#{type}_event".to_sym)
  @event.interested_party.person_entity.person.last_name = @staged_message.patient.patient_name.split(',').first
  @event.interested_party.person_entity.person.birth_date = @staged_message.patient.birth_date
  @event.build_jurisdiction
  @event.jurisdiction.secondary_entity = Place.jurisdiction_by_name("Unassigned").entity
  @event.save!
end

Given /^that event also has a middle name of (.+)$/ do |m_name|
  @event.interested_party.person_entity.person.middle_name = m_name
  @event.save
end

When /^I click the '(.+)' link of the found event$/ do |link|
  # JavaScript!!!
  # click_link_within "#event_#{@event.id}",  link
  submit_form "assign_#{@event.id}"
end

When /^I click 'Create a CMR from this message'$/ do
  # JavaScript!!!
  submit_form "assign_to_new"
end

Then /^I should see a '(.+)' message$/ do |msg|
  # Flash message
  response.should contain(msg)
end

Then /^I should see a state of '(.+)'$/ do |state|
  response.should contain(/State:\s+#{state}/)
end

Then /^I should remain on the staged message show page$/ do
  path = staged_message_path(@staged_message)
  current_url.should =~ /#{path}/
end

Then /^I should not see the '(.+)' link$/ do |text|
  response.should_not contain(text)
end

When /^I visit the assigned-to event$/ do
  click_link 'Assigned'
end

Given /^the following loinc code to common test types mapping exists$/ do |loinc_test_maps|
  @scale = CodeName.loinc_scale.external_codes.first
  loinc_test_maps.rows.each do |loinc_test_map|
    d = LoincCode.new(:loinc_code => loinc_test_map.first, :scale_id => @scale.id)
    d.build_common_test_type(:common_name => loinc_test_map.last) unless loinc_test_map.last.blank?
    d.save
  end
end

Then /^I should see the new lab result with '(.+)'$/ do |test_type|
  response.should contain(@staged_message.message_header.sending_facility)
  response.should contain(test_type)
  response.should contain(@staged_message.observation_requests.first.tests.first.result)
  response.should contain(@staged_message.observation_requests.first.collection_date)
  response.should contain(/#{@staged_message.observation_requests.first.specimen_source}/i)
  response.should contain(@staged_message.observation_requests.first.tests.first.reference_range)
  response.should contain(@staged_message.observation_requests.first.tests.first.observation_date)
end

Then /^I should see a middle name of (.+)$/ do |m_name|
  response.should have_selector("span[class='data_middle_name']") do |mid_name|
    mid_name.should contain(m_name)
  end
end

Then /^I should see the patient information$/ do
  response.should have_selector("#demographic_tab") do |frag|
    frag.should contain(@staged_message.patient.patient_last_name)
    frag.should contain(@staged_message.patient.patient_first_name)
    frag.should contain(@staged_message.patient.patient_middle_name)

    frag.should contain(@staged_message.patient.address_street_no)
    frag.should contain(@staged_message.patient.address_street)
    frag.should contain(@staged_message.patient.address_unit_no)
    frag.should contain(@staged_message.patient.address_city)
    frag.should contain(ExternalCode.find(@staged_message.patient.address_trisano_state_id).code_description)
    frag.should contain(@staged_message.patient.address_zip)

    area, num, ext = @staged_message.patient.telephone_home
    frag.should contain("Home: (#{area}) #{num[0..2]}-#{num[3..6]}")
  end
end

When /^I click the 'Discard' link for the staged message$/ do
  submit_form "discard_#{@staged_message.id}"
end

Then /^I should not see the discarded message$/ do
  response.should_not have_selector("#message_#{@staged_message.id}")
end

Then /^I should see a note for the assigned lab$/ do
  response.should have_xpath("//div[@id='note-list']//p[text()='ELR with test type \"#{@staged_message.observation_requests.first.tests[0].test_type}\" assigned to event.']")
end

Then /^I should see a link back to the staged message$/ do
  response.should have_xpath("//a[@href='#{staged_message_path(@staged_message)}']")
end

When /^I visit the editable event$/ do
  click_link 'Edit'
end

Then %r{^I should see "([^\"]*)" under Telephones/Email on the Demographic tab} do |phone_type|
  response.should have_xpath("//div[@id='demographic_tab']//div[@class='data_telephones']//span[contains(text(), '#{phone_type}')]")
end

Then %r{^I should see "([^\"]*)" under Ethnicity on the Demographic tab$} do |ethnicity|
  response.should have_xpath("//div[@id='demographic_tab']//span[@class='data_ethnicity'][contains(text(), '#{ethnicity}')]")
end

Then %r{^I should see "([^\"]*)" on the Laboratory tab$} do |text|
  response.should have_xpath("//div[@id='lab_info_tab']//div[@id='labs']//b[contains(text(), '#{text}')]")
end

Then %r{^I should see "([^\"]*)" on the Clinical tab$} do |text|
  response.should contain text

  # DEBT: This test is too weak, but why doesn't this work?
  # response.should have_xpath("//div[@id='clinical_tab'][contains(text(), '#{text}')]")
end
