Given(/^I am logged in as a super user$/) do
  switch_user(@browser, 'default_user')
end

Then(/^I should be presented with the error message \"(.+)\"$/) do |message|
  @browser.is_text_present(message).should be_true
end
