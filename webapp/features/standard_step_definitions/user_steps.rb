Given /^I have the following email addresses:$/ do |table|
  table.raw.map(&:first).each do |email|
    User.current_user.email_addresses.create(:email_address => email)
  end
end

Given /^a user with uid "([^\"]*)"$/ do |uid|
  @user = User.find_by_uid(uid)
  unless @user
    @user = Factory.create(:user, :uid => uid, :user_name => uid)
  end
end

Given /^"([^\"]*)" is an investigator in "([^\"]*)"$/ do |uid, jurisdiction_name|
  Given %{a user with uid "#{uid}"}
  jurisdiction = Place.jurisdictions.select { |j| j.short_name == jurisdiction_name }.first
  role = Role.find_by_role_name('Investigator')
  @user.role_memberships.create(:jurisdiction_id => jurisdiction.entity_id, :role => role)
end

