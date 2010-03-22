Then /^I should see the event\'s lab in the results$/ do
  response.should have_selector('tr.search-active') do |tr|
    tr.should contain(@event.labs.first.place_entity.place.name)
  end
end
