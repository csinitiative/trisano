When /^I go to edit the user$/ do
  @browser.click "link=ADMIN"
  @browser.wait_for_page_to_load
  @browser.click "link=Manage Users"
  @browser.wait_for_page_to_load
  @browser.click "link=#{@user.uid}"
  @browser.wait_for_page_to_load
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load
end

When /^I remove the role$/ do
  @browser.click "link=Remove"
end

Given /^the user has the role "([^\"]*)" in the "([^\"]*)"$/ do |role, jurisdiction|
  jurisdiction_id = Place.jurisdiction_by_name(jurisdiction).id
  role_id = Role.find_by_role_name(role).id
  RoleMembership.create :user_id => @user.id, :jurisdiction_id => jurisdiction_id, :role_id => role_id
end

After('@clean_user') do
  @user.destroy if @user
end
