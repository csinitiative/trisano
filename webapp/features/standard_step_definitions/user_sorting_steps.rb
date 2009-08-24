Given /^the default system users$/ do
  # this is here as a place holder, and because I wanted to be
  # explicit in my scenarios describing users.
end

Then /^uid "([^\"]*)" should appear before uid "([^\"]*)"$/ do |first, second|
  response.should have_xpath("//a[text() = '#{first}']/following::a[text() = '#{second}']")
end

Then /^user status "([^\"]*)" should not appear after user status "([^\"]*)"$/ do |first, second|
  response.should_not have_xpath("//span[@id='user-status' and text()='#{second}']/following::span[@id='user-status' and text()='#{first}']")
end

Then /^user name "([^\"]*)" should not appear after user name "([^\"]*)"$/ do |first, second|
  response.should_not have_xpath("//a[text()='#{second}']/following::a[text()='#{first}']")
end

Then /^"([^\"]*)" should be selected from "([^\"]*)"$/ do |value, field|
  response.should have_xpath("//select[@id='#{field}']//option[text()='#{value}' and @selected='selected']")
end

Given /^user "([^\"]*)" is disabled$/ do |uid|
  @user = User.find_by_uid uid
  @user.disable
end



