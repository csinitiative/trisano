
Given /^a state manager is assigned to the event$/ do
  @event.state_manager = create_user_in_role!("State Manager", "Dave Wilson")
  @event.save!
end

When /^I enter a valid expected delivery date$/ do
  fill_in "Expected delivery date", :with => Date.today + 2
end


#
# Tags
#
Before('@perinatal_hep_b_callbacks') do
  DiseaseSpecificCallback.create_perinatal_hep_b_associations
end
