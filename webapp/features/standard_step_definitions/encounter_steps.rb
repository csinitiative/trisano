Given /the event has an encounter$/ do
  @encounter = @event.encounter_child_events.create
end

Given /the encounter investigator is "(.*)"$/ do |uid|
  Given %{a user with uid "#{uid}"}
  if @encounter.participations_encounter
    @encounter.participations_encounter.update_attributes!(:user_id => @user.id)
  else
    @participations_encounter = ParticipationsEncounter.create!(:user_id => @user.id, :encounter_date => Date.yesterday, :encounter_location_type => ParticipationsEncounter.valid_location_types.first)
    @encounter.update_attributes!(:participations_encounter => @participations_encounter)
  end
end

Then /^I should see "(.+)" in the encounters table$/ do |expected|
  response.should have_tag('table#encounters') do
    with_tag("td", expected)
  end
end

Then /^I should not see "(.+)" in the encounters table$/ do |expected|
  response.should have_tag('table#encounters') do
    without_tag("td", expected)
  end
end
