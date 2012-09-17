Given /^I have (a|another) common test type named (.*)$/ do |a, common_name|
  @common_test_type = Factory.create(:common_test_type, :common_name => common_name)
end

When /^I debug$/ do
  debugger
end

