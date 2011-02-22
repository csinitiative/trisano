Given /^the event has a reporter$/ do
  @reporter_entity = Factory.create(:person_entity)
  @reporter = @reporter_entity.person
  @event.build_reporter(:secondary_entity => @reporter_entity)
  @event.save!
end

When /^I select a reporter from the reporter drop down$/ do
  @browser.select "css=#_reporter_id", @reporter.last_comma_first
  @browser.wait_for_condition "selenium.browserbot.getCurrentWindow().jQuery.active == 0"
end

Then /^I should see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporter span').text();"
  @browser.get_eval(script).should =~ /#{@reporter.last_comma_first}/
end

Then /^I should not see the reporter on the page$/ do
  script = "selenium.browserbot.getCurrentWindow().$j('#reporter span').text();"
  @browser.get_eval(script).should_not =~ /#{@reporter.last_comma_first}/
end

When /^I click on the remove reporter link$/ do
  @browser.click "//div[@id='reporter']//a[text()='Remove']"
end

Then /^I should see the reporter form$/ do
  %w(morbidity_event_reporter_attributes_person_entity_attributes_person_attributes_last_name
     morbidity_event_reporter_attributes_person_entity_attributes_person_attributes_first_name
     morbidity_event_reporter_attributes_person_entity_attributes_telephones_attributes_0_area_code
     morbidity_event_reporter_attributes_person_entity_attributes_telephones_attributes_0_phone_number
     morbidity_event_reporter_attributes_person_entity_attributes_telephones_attributes_0_extension
     morbidity_event_reporter_attributes_secondary_entity_id).each do |id|
    @browser.get_xpath_count("//div[@id='reporter']//input[@id='#{id}']").to_i.should >= 1
  end
end

When /^I remove the reporter from the event$/ do
  @browser.click "//div[@id='reporter']//input[@type='checkbox']"
  When %{I save and continue}
end
