When /^in a (.+) event, I search for a diagnostic facility named "([^\"]*)"$/ do |event_type, name|
  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :diagnostic_facilities_search,
                  :name => name })
end

When /^in a (.+) event, I search for a place exposure named "([^\"]*)"$/ do |event_type, name|
  codes = Place.epi_type_codes.map do |the_code|
    Code.find_by_code_name_and_the_code('placetype', the_code).id
  end

  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :places_search,
                  :name => name, :types => "[#{codes.join(',')}]"})
end

When /^in a (.+) event, I search for a reporting agency named "([^\"]*)"$/ do |event_type, name|
  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :reporting_agencies_search,
                  :place_name => name,
                  :event_type => 'morbidity_event' })
end

When /^I search for a contact named "([^\"]*)"$/ do |arg1|
  visit url_for({ :controller => :events,
                  :action => :contacts_search,
                  :contact_search_name => name })
end

