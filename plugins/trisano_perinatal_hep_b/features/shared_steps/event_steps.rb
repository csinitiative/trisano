Given /^a state manager is assigned to the event$/ do
  @state_manager = User.state_managers.first
  unless @state_manager
    @state_manager = create_user_in_role!("State Manager", "Dave Wilson")
  end
  @event.state_manager = @state_manager
  @event.save!
end

Given /^the expected delivery date is set to (\d+) days from now$/ do |days|
  if @event.interested_party.risk_factor
    @event.interested_party.risk_factor.pregnancy_due_date = Date.today + days.to_i
  else
    @event.interested_party.build_risk_factor(:pregnancy_due_date => Date.today + days.to_i)
  end
  @event.save!
end

