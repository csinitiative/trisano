Then /^I should not see expected delivery fields$/ do
  response.should_not have_tag('span', 'Expected delivery facility')
end

Then /^I should see expected delivery facility fields$/ do
  response.should have_tag('#disease_info_form .form') do
    with_tag("#expected_delivery_facility") do
      with_tag('.vert:nth-of-type(1) label', 'Expected delivery facility') do
        with_tag('+ input')
      end
      with_tag('.horiz:nth-of-type(3) label', 'Area code') do
        with_tag('+ input')
      end
      with_tag('.horiz:nth-of-type(4) label', 'Phone number') do
        with_tag('+ input')
      end
      with_tag('.horiz:nth-of-type(5) label', 'Extension') do
        with_tag('+ input')
      end
    end
  end
end

Then /^I should see expected delivery data$/ do
  response.should have_tag('#clinical_tab fieldset .form') do
    with_tag('.vert label', 'Expected delivery facility')
    with_tag('.horiz label', 'Area code')
    with_tag('.horiz label', 'Phone number')
    with_tag('.horiz label', 'Extension')
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

Then /^I should see printed expected delivery fields$/ do
  response.should have_tag('.section-header') do
    assert_contain('Clinical Information')
    with_tag('~ .horiz .print-label', 'Expected delivery date:')
    with_tag('~ .horiz .print-label', 'Expected delivery facility:')
  end
end

Then /^I should see printed expected delivery facility phone numbers:$/ do |phone_number_table|
  phone_number_table.hashes.each do |hash|
    hash.each do |k, v|
      response.should have_tag('.horiz .print-label', k.to_s + ':')
      response.should have_tag('.horiz .print-value', v)
    end
  end
end

