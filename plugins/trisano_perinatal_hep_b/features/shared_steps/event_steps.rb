Given /^a state manager is assigned to the event$/ do
  @state_manager = User.state_managers.first
  unless @state_manager
    @state_manager = create_user_in_role!("State Manager", "Dave Wilson")
  end
  @event.state_manager = @state_manager
  @event.save!
end

