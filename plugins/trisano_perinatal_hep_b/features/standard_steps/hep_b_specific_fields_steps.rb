Then /^I should not see (.+) delivery fields$/ do |type|
  assert_no_delivery_fields(type)
end

Then /^I should see (.+) delivery facility fields$/ do |type|
  assert_delivery_fields(type)
end

Then /^I should see (.+) delivery data$/ do |type|
  assert_delivery_fields(type)
end

Then /^I should not see (.+) delivery data$/ do |type|
  assert_no_delivery_fields(type)
end

Given /^I have an actual delivery date of (\d+) days ago$/ do |days|
  date = days.to_i.days.ago
  @event.update_attributes! :actual_delivery_date => date
end

When /^I enter the (.+) delivery facility phone number as:/ do |type, phone_number_table|
  name_prefix =  "morbidity_event[#{type}_delivery_facility_attributes][place_entity_attributes][telephones_attributes][0]"
  phone_number_table.hashes.each do |hash|
    hash.each do |k, v|
      fill_in(name_prefix + "[#{k}]", :with => v)
    end
  end
end

Then /^I should see the (.+) delivery facility phone number as:/ do |type, phone_number_table|
  phone_number_table.hashes.each do |hash|
    hash.values.each do |v|
      assert_contain(v)
    end
  end
end

Then /^I should see printed (.*) delivery fields$/ do |type|
  assert_printed_field(:clinical, "#{type.capitalize} delivery date:")
  assert_printed_field(:clinical, "#{type.capitalize} delivery facility:")
end

Then /^I should see printed (.+) delivery facility phone numbers:$/ do |type, phone_number_table|
  phone_number_table.hashes.each do |hash|
    hash.each do |k, v|
      response.should have_tag('.horiz .print-label', k.to_s + ':')
      response.should have_tag('.horiz .print-value', v)
    end
  end
end

Given /^a Hepatitis B Pregnancy Event exists$/ do
  @event = create_basic_event('morbidity', 'Squarepants', 'Hepatitis B Pregnancy Event')
end

Then /^I should see state manager "([^\"]*)"$/ do |name|
  assert_state_manager_data(name)
end

Then /^I should see state manager "([^\"]*)" printed$/ do |manager_name|
  assert_printed_field(:administrative, "State manager:")
end

Then /^I should not see the "([^\"]*)" select$/ do |label_text|
  assert_no_tag 'label', {
    :content => label_text,
    :before => {
      :tag => 'select'
    }
  }
end

