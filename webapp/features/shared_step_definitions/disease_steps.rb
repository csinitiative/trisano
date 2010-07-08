Given /^disease "([^\"]*)" exists$/ do |name|
  @disease = Factory.create(:disease, :disease_name => name)
end
