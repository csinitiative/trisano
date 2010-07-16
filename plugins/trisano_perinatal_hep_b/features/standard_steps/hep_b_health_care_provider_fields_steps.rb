def path_to_hcp_name_fieldset
  "fieldset fieldset:nth-of-type(1) div"
end

def path_to_hcp_telephone_fieldset
  "fieldset fieldset:nth-of-type(2)"
end

Then /^I should not see health care provider fields$/ do
  response.should have_tag('#health_care_provider') do
    without_tag('fieldset legend', 'Health Care Provider')
    without_tag("#{path_to_hcp_name_fieldset} div span:nth-of-type(1) label", 'Last name')
  end
end

Then /^I should see health care provider fields$/ do
  response.should have_tag('#disease_info_form .form') do
    with_tag("#health_care_provider") do
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(1) label", 'Last name')
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(2) label", 'First name')
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(3) label", 'Middle name')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(1) label", 'Area code')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(2) label", 'Phone number')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(3) label", 'Extension')
    end
  end
end

When /^I enter the health care provider name as:$/ do |name_table|
  name_prefix =  'morbidity_event[health_care_provider_attributes][person_entity_attributes][person_attributes]'
  name_table.hashes.each do |hash|
    hash.each do |k, v|
      fill_in(name_prefix + "[#{k}]", :with => v)
    end
  end
end

When /^I enter the health care provider phone number as:$/ do |phone_table|
  name_prefix =  'morbidity_event[health_care_provider_attributes][person_entity_attributes][telephones_attributes][0]'
  phone_table.hashes.each do |hash|
    hash.each do |k, v|
      fill_in(name_prefix + "[#{k}]", :with => v)
    end
  end
end

Then /^I should see health care provider data$/ do
  response.should have_tag('#clinical_tab fieldset .form') do
    with_tag("#health_care_provider") do
      with_tag('legend', 'Health Care Provider')
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(1) label", 'Last name')
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(2) label", 'First name')
      with_tag("#{path_to_hcp_name_fieldset} span:nth-of-type(3) label", 'Middle name')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(1) label", 'Area code')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(2) label", 'Phone number')
      with_tag("#{path_to_hcp_telephone_fieldset} span:nth-of-type(3) label", 'Extension')
    end
  end
end

Then /^I should see the health care provider phone number as:$/ do |phone_table|
  phone_table.hashes.each do |hash|
    hash.values.each do |v|
      assert_contain(v)
    end
  end
end

Then /^I should see printed health care provider fields$/ do
  assert_printed_field(:clinical, "Health Care Provider first name:")
  assert_printed_field(:clinical, "Health Care Provider last name:")
  assert_printed_field(:clinical, "Health Care Provider middle name:", :vert)
end

Then /^I should see printed health care provider phone numbers:$/ do |phone_table|
  phone_table.hashes.each do |hash|
    hash.each do |k, v|
      response.should have_tag('.horiz .print-label', k.to_s + ':')
      response.should have_tag('.horiz .print-value', v)
    end
  end
end

