
When /^I enter a valid expected delivery date$/ do
  fill_in "Expected delivery date", :with => Date.today + 2
end

When /^I change the expected delivery date to (\d+) days from now$/ do |days|
  fill_in "Expected delivery date", :with => Date.today + days.to_i
end

Then /^I should only see (\d+) "([^\"]*)" task$/ do |count, task_name|
  assert_tag 'tbody', {
    :children => {
      :count => count.to_i,
      :only => {
        :tag => 'tr',
        :child => { :tag => 'td', :content => Regexp.new(task_name) }
      }
    }
  }
end

#
# Tags
#
Before('@perinatal_hep_b_callbacks') do
  DiseaseSpecificCallback.create_perinatal_hep_b_associations
end
