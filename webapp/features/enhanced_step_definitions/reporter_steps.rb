Given /^the event has a reporter$/ do
  @reporter_entity = Factory.create(:person_entity)
  @reporter = @reporter_entity.person
  @event.build_reporter(:secondary_entity => @reporter_entity)
  @event.save!
end

When /^I add an existing reporter$/ do
  click_core_tab(@browser, "Reporting")
  @browser.type('reporter_search_name', @reporter_entity.person.last_name)
  @browser.click('reporter_search')
  wait_for_element_present("//div[@id='reporter_search_results']/table")
  @browser.click "//div[@id='reporter_search_results']//a[@id='add_reporter_entity_#{@reporter_entity.id}']"
  wait_for_element_present("//div[@id='existing-reporter']")
end

Then /^I should see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporters').text();"
  wait_for_element_present("//div[@id='reporters']")
  @browser.get_eval(script).should =~ /#{@reporter.last_comma_first}/
end

Then /^I should not see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporters').text();"
  wait_for_element_present("//div[@id='reporters']")
  @browser.get_eval(script).should_not =~ /#{@reporter.last_comma_first}/
end

Then /^I should see the reporter form$/ do
  event_type = @event.class.to_s.underscore
    ["#{event_type}_reporter_attributes_person_entity_attributes_person_attributes_last_name",
     "#{event_type}_reporter_attributes_person_entity_attributes_person_attributes_first_name",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_area_code",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_phone_number",
     "#{event_type}_reporter_attributes_person_entity_attributes_telephones_attributes_0_extension"].each do |id|
    @browser.get_xpath_count("//div[@id='reporters']//input[@id='#{id}']").to_i.should == 1
  end
end

When /^I remove the reporter from the event$/ do
  @browser.click "//input[@id='#{@event.class.to_s.underscore}_reporter_attributes__destroy']"
  When %{I save and continue}
end
