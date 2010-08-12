Then /^I should see the expected delivery facility fields$/ do
  assert(@browser.element?('css=#disease_info_form .form #expected_delivery_facility'))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='vert']/label[text()='Expected delivery facility']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Area code']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Phone number']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Extension']/../input"))
end

Then /^I should see the actual delivery facility fields$/ do
  assert(@browser.element?('css=#disease_info_form .form #actual_delivery_facility'),
         "Missing #actual_delivery_facility container")
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']/*[@class='vert']/label[text()='Actual delivery facility']/../input"),
         "Missing Actual delivery facility field")
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']/*[@class='horiz']/label[text()='Area code']/../input"),
         "Missing actual delivery facility area code")
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']/*[@class='horiz']/label[text()='Phone number']/../input"),
         "Missing actual delivery facility phone number")
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']/*[@class='horiz']/label[text()='Extension']/../input"),
         "Missing actual delivery facility extension")
end

When /^I complete the expected delivery facility fields$/ do
  @browser.click("css=a[href='#clinical_tab']")
  @browser.type("xpath=//label[text()='Expected delivery facility']/../input", "New Expected Delivery Facility")
  @browser.check("morbidity_event_expected_delivery_facility_attributes__place_entity_attributes__place_attributes_place_type_H")
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Area code']/../input", '999')
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Phone number']/../input", "555-1234")
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Extension']/../input", '888')
end

When /^I complete the actual delivery facility fields$/ do
  @browser.click("css=a[href='#clinical_tab']")
  @browser.type("xpath=//label[text()='Actual delivery facility']/../input", "New Actual Delivery Facility")
  @browser.check("morbidity_event_actual_delivery_facility_attributes__place_entity_attributes__place_attributes_place_type_H")
  @browser.type("xpath=//*[@id='actual_delivery_facility']//label[text()='Area code']/../input", '999')
  @browser.type("xpath=//*[@id='actual_delivery_facility']//label[text()='Phone number']/../input", "555-5678")
  @browser.type("xpath=//*[@id='actual_delivery_facility']//label[text()='Extension']/../input", '77')
end

When /^I save and continue$/ do
  @browser.click("//*[@id='save_and_continue_btn']")
  @browser.wait_for_page_to_load
end

Then /^I should see the expected delivery facility data$/ do
  @browser.wait_for_element("css=#expected_delivery_facility a")
  @browser.wait_for_element("xpath=//label[text()='Expected delivery facility']")
  assert_match(/New Expected Delivery Facility/, @browser.get_text("xpath=//label[text() = 'Expected delivery facility']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Place type']"))
  assert_match(/Hospital/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Place type']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Area code']"))
  assert_match(/\(999\)/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Area code']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Phone number']"))
  assert_match(/555-1234/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Phone number']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Extension']"))
  assert_match(/888/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Extension']/.."))
end

Then /^I should see the actual delivery data$/ do
  @browser.wait_for_element("css=#actual_delivery_facility a")
  @browser.wait_for_element("xpath=//label[text()='Actual delivery facility']")
  assert_match(/New Actual Delivery Facility/, @browser.get_text("xpath=//label[text() = 'Actual delivery facility']/.."))
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']//label[text()='Place type']"))
  assert_match(/Hospital/, @browser.get_text("xpath=//*[@id='actual_delivery_facility']//label[text() = 'Place type']/.."))
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']//label[text()='Area code']"))
  assert_match(/\(999\)/, @browser.get_text("xpath=//*[@id='actual_delivery_facility']//label[text() = 'Area code']/.."))
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']//label[text()='Phone number']"))
  assert_match(/555-5678/, @browser.get_text("xpath=//*[@id='actual_delivery_facility']//label[text() = 'Phone number']/.."))
  assert(@browser.element?("xpath=//*[@id='actual_delivery_facility']//label[text()='Extension']"))
  assert_match(/77/, @browser.get_text("xpath=//*[@id='actual_delivery_facility']//label[text() = 'Extension']/.."))
end

Then /^I should see the actual delivery date field$/ do
  assert(@browser.element?('morbidity_event_actual_delivery_facility_attributes_actual_delivery_facilities_participation_attributes_actual_delivery_date'),
         "Actual delivery date is missing")
end

When /^I remove the expected delivery data$/ do
  link = "//div[@id='expected_delivery_facility']//a[contains(text(), 'Remove')]"
  @browser.click(link)
  @browser.wait_for_ajax
end

When /^I remove the actual delivery data$/ do
  link = "//div[@id='actual_delivery_facility']//a[contains(text(), 'Remove')]"
  @browser.click(link)
  @browser.wait_for_ajax
end

When /^I search for an expected delivery facility$/ do
  @browser.type("xpath=//label[text()='Expected delivery facility']/../input", "New Exp")
  @browser.type_keys("xpath=//label[text()='Expected delivery facility']/../input", "e")
  @browser.wait_for_ajax
end

When /^I search for an actual delivery facility$/ do
  @browser.type("xpath=//label[text()='Actual delivery facility']/../input", "New Act")
  @browser.type_keys("xpath=//label[text()='Actual delivery facility']/../input", "u")
  @browser.wait_for_ajax
end

When /^I select an expected delivery facility from the list$/ do
  @browser.wait_for_element("xpath=//div[@class='autocomplete']/ul/li[contains(text(), 'New Expected Delivery Facility')]")
  @browser.type_keys("xpath=//label[text()='Expected delivery facility']/../input", "\t")
  @browser.wait_for_ajax
end

When /^I select an actual delivery facility from the list$/ do
  @browser.wait_for_element("xpath=//div[@class='autocomplete']/ul/li[contains(text(), 'New Actual Delivery Facility')]")
  @browser.type_keys("xpath=//label[text()='Actual delivery facility']/../input", "\t")
  @browser.wait_for_ajax
end

Given /^there is an (.+) facility named "([^\"]*)"$/ do |type, name|
  create_place!(type.gsub(' ', '_'), name)
end

When /^I fill in the actual delivery date$/ do
  @browser.type('morbidity_event_actual_delivery_facility_attributes_actual_delivery_facilities_participation_attributes_actual_delivery_date',
                'January 10, 2010')
end

When /^I fill in the expected delivery date$/ do
  @browser.type('morbidity_event_interested_party_attributes_risk_factor_attributes_pregnancy_due_date',
                Date.today + 2)
end

Then /^I should see the actual delivery date filled in$/ do
  value = @browser.get_value("morbidity_event_actual_delivery_facility_attributes_actual_delivery_facilities_participation_attributes_actual_delivery_date")
  assert_equal("January 10, 2010", value)
end

Given /^Perinatal Hep B specific callbacks are loaded$/i do
  DiseaseSpecificCallback.create_perinatal_hep_b_associations
end
