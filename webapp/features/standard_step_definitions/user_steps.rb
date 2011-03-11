Given /^I have the following email addresses:$/ do |table|
  table.raw.map(&:first).each do |email|
    User.current_user.email_addresses.create(:email_address => email)
  end
end
