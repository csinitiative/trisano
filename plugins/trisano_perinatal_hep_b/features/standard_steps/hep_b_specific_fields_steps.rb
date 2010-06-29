Then /^I should not see expected delivery fields$/ do
  response.should_not have_tag('legend', 'Expected Delivery Information')
end

Then /^I should see expected delivery facility fields$/ do
  response.should have_tag('#disease_info_form .form') do
    with_tag('legend:nth-of-type(2)', 'Expected Delivery')
    with_tag('.vert:nth-of-type(3) label', 'Expected delivery date') do
      with_tag('+ input')
    end
    with_tag('.vert:nth-of-type(4) label', 'Expected delivery facility') do
      with_tag('+ input')
    end
    with_tag('.horiz:nth-of-type(5) label', 'Area code') do
      with_tag('+ input')
    end
    with_tag('.horiz:nth-of-type(6) label', 'Phone number') do
      with_tag('+ input')
    end
    with_tag('.horiz:nth-of-type(7) label', 'Extension') do
      with_tag('+ input')
    end
  end
end

Then /^I should see expected delivery data$/ do
  response.should have_tag('#clinical_tab fieldset .form') do
    with_tag('fieldset.vert legend', 'Expected Delivery') do
      with_tag('~ .vert label', 'Expected delivery date')
      with_tag('~ .horiz label', 'Expected delivery facility')
      with_tag('~ .horiz label', 'Area code')
      with_tag('~ .horiz label', 'Phone number')
      with_tag('~ .horiz label', 'Extension')
    end
  end
end

When /^I enter the expected delivery facility phone number as:/ do |phone_number_table|
  name_prefix =  'morbidity_event[expected_delivery_facility_attributes][place_entity_attributes][telephones_attributes][0]'
  phone_number_table.hashes.each do |hash|
    hash.each do |k, v|
      fill_in(name_prefix + "[#{k}]", :with => v)
    end
  end
end

Then /^I should see the expected delivery facility phone number as:/ do |phone_number_table|
  phone_number_table.hashes.each do |hash|
    hash.values.each do |v|
      assert_contain(v)
    end
  end
end

