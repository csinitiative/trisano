Given /^I have selected the "([^\"]*)" locale$/ do |locale|
  visit home_path
  select locale, :from => 'Language:'
  submit_form 'select-locale'
end

Then /^I should still see locale "([^\"]*)"$/ do |locale|
  current_url.should =~ /locale=#{locale}$/i
end

Then /^I should see "([^\"]*)" as the default locale$/ do |language|
  response.should have_xpath("//table//td//div[contains(text(), language)]")
end

Then /^I should see default locale headers$/ do
  response.should have_xpath("//table//th[contains(text(), 'Current Locale')]")
  response.should have_xpath("//table//th[contains(text(), 'Modified by')]")
  response.should have_xpath("//table//th[contains(text(), 'Last Modified')]")
end

When /^I submit the default locale edit form$/ do
  submit_form "edit_default_locale"
end
