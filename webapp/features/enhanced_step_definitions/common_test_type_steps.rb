Given /^no other common test types exist$/ do
  CommonTestType.all.each { |tt| tt.destroy unless tt == @lab_result.test_type }
end

When /^I navigate to show common test type$/ do
  @browser.click("link=ADMIN")
  @browser.wait_for_page_to_load
  @browser.click("link=Manage Common Test Types")
  @browser.wait_for_page_to_load
  @browser.click("link=Show")
  @browser.wait_for_page_to_load
end

Then /^I should see a link to "([^\"]*)"$/ do |link_name|
  @browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i.should == 1
  @browser.visible?("//a[contains(text(), '#{link_name}')]").should be_true
end

Then /^I should not see a link to "([^\"]*)"$/ do |link_name|
  # this let's us ignore invisible links
  if @browser.visible?("//a[contains(text(), '#{link_name}')]")
    @browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i.should == 0
  end
end

After('@clean_common_test_types') do
  CommonTestType.all.each(&:delete)
end

After('@clean_lab_results') do
  LabResult.all.each(&:delete)
end
