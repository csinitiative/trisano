Given /^I have (a|another) common test type named (.*)$/ do |a, common_name|
  @common_test_type = Factory.create(:common_test_type, :common_name => common_name)
end

When /^I debug$/ do
  debugger
end

Then /^I should (.+) a label "(.+)"$/ do |see_not_see, label_text|
  label_occurances = @browser.get_xpath_count("//label[text()='#{label_text}']").to_i

  if see_not_see == "see"
    label_occurances.should >(0)
  elsif see_not_see == "not see"
    label_occurances.should ==(0)
  else
    raise "Unexpected instruction: #{see_not_see}"
  end
end
