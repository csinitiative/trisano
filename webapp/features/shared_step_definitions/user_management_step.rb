Given /^I have a user with the UID "([^\"]*)" and user name "([^\"]*)"$/ do |uid, user_name|
  @user = User.create! :uid => uid, :user_name => user_name
end

Given /^a (.+) exists named "([^\"]*)"$/ do |role_name, user_name|
  create_user_in_role!(role_name, user_name)
end
