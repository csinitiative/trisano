When /^I search for a diagnostic facility named "([^\"]*)"$/ do |name|
  visit url_for({ :controller => :morbidity_events,
                  :action => :diagnostic_facilities_search,
                  :name => name })
end

When /^I search for a place exposure named "([^\"]*)"$/ do |name|
  codes = Place.epi_type_codes.map do |the_code|
    Code.find_by_code_name_and_the_code('placetype', the_code).id
  end

  visit url_for({ :controller => :morbidity_events,
                  :action => :places_search,
                  :name => name, :types => "[#{codes.join(',')}]"})
end

When /^I search for a reporting agency named "([^\"]*)"$/ do |name|
  visit url_for({ :controller => :morbidity_events,
                  :action => :reporting_agencies_search,
                  :place_name => name,
                  :event_type => 'morbidity_event' })
end

When /^I search for a contact named "([^\"]*)"$/ do |arg1|
  visit url_for({ :controller => :events,
                  :action => :contacts_search,
                  :contact_search_name => name })
end

