Given /^I am logged in as a super user$/ do
  @browser.open "/trisano/cmrs"
  click_logo(@browser)
end