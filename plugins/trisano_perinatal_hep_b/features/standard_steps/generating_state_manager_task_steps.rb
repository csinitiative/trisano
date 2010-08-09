
Given /^a state manager is assigned to the event$/ do
  @event.state_manager = create_user_in_role!("State Manager", "Dave Wilson")
  @event.save!
end

When /^I enter a valid expected delivery date$/ do
  fill_in "Expected delivery date", :with => Date.today + 2
end

Given /^a the expected delivery date is set to (\d+) days from now$/ do |days|
  if @event.interested_party.risk_factor
    @event.interested_party.risk_factor.pregnancy_due_date = Date.today + days.to_i
  else
    @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + days.to_i)
  end
  @event.save!
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
