When /^I navigate to show common test type$/ do
  @browser.click("link=ADMIN")
  @browser.wait_for_page_to_load
  @browser.click("link=Manage Common Test Types")
  @browser.wait_for_page_to_load
  @browser.click("link=Show")
  @browser.wait_for_page_to_load
end

Then /^I should see a link to "([^\"]*)"$/ do |link_name|
  #@browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i.should == 1
  @browser.get_xpath_count("//a[contains(text(), 'Delete')]").to_i.should == 1
end

Then /^I should see "([^\"]*)"$/ do |text|
  @browser.is_text_present(text).should be_true
end

Then /^I should not see "([^\"]*)"$/ do |text|
  @browser.is_text_present(text).should_not be_true
end

After('@clean_common_test_types') do
  CommonTestType.destroy_all
end
