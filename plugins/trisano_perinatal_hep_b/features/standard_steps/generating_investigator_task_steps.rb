
Given /^an investigator is assigned to the event$/ do
  @event.investigator = create_user_in_role!("Investigator", "Dave Wilson")
  @event.save!
end
