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
  links_found = @browser.get_xpath_count("//a[contains(text(), '#{link_name}')]").to_i
  if links_found == 0
    links_found.should be_equal(0)
  else
    # this let's us ignore invisible links
    # but not check for them if they don't exist
    @browser.visible?("//a[contains(text(), '#{link_name}')]")
  end
end

After('@clean_common_test_types') do
  CommonTestType.all.each(&:delete)
end

After('@clean_lab_results') do
  LabResult.all.each(&:delete)
end
