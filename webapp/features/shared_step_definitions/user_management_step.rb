Given /^I have a user with the UID "([^\"]*)" and user name "([^\"]*)"$/ do |uid, user_name|
  @user = User.create! :uid => uid, :user_name => user_name
end
