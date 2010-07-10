Then /^I should see the expected delivery facility fields$/ do
  assert(@browser.element?('css=#disease_info_form .form #expected_delivery_facility'))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='vert']/label[text()='Expected delivery facility']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Area code']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Phone number']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Extension']/../input"))
end

When /^I complete the expected delivery facility fields$/ do
  @browser.click("css=a[href='#clinical_tab']")
  @browser.type("xpath=//label[text()='Expected delivery facility']/../input", "New Expected Delivery Facility")
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Area code']/../input", '999')
  @browser.check("morbidity_event_expected_delivery_facility_attributes__place_entity_attributes__place_attributes_place_type_H")
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Phone number']/../input", "555-1234")
  @browser.type("xpath=//*[@id='expected_delivery_facility']//label[text()='Extension']/../input", '888')
end

When /^I save and continue$/ do
  @browser.click("//*[@id='save_and_continue_btn']")
  @browser.wait_for_page_to_load
end

Then /^I should see the expected delivery facility data$/ do
  @browser.wait_for_element("css=#expected_delivery_facility a")
  @browser.wait_for_element("xpath=//label[text()='Expected delivery facility']")
  assert_match(/New Expected Delivery Facility/, @browser.get_text("xpath=//label[text() = 'Expected delivery facility']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Place types']"))
  assert_match(/Hospital/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Place types']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Area code']"))
  assert_match(/\(999\)/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Area code']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Phone number']"))
  assert_match(/555-1234/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Phone number']/.."))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']//label[text()='Extension']"))
  assert_match(/888/, @browser.get_text("xpath=//*[@id='expected_delivery_facility']//label[text() = 'Extension']/.."))
end

When /^I remove the expected delivery data$/ do
  link = "//div[@id='expected_delivery_facility']//a[contains(text(), 'Remove')]"
  @browser.click(link)
  @browser.wait_for_ajax
end

When /^I search for an expected delivery facility$/ do
  @browser.type("xpath=//label[text()='Expected delivery facility']/../input", "New Exp")
  @browser.type_keys("xpath=//label[text()='Expected delivery facility']/../input", "e")
  @browser.wait_for_ajax
end

When /^I select an expected delivery facility from the list$/ do
  @browser.wait_for_element("xpath=//div[@class='autocomplete']/ul/li[contains(text(), 'New Expected Delivery Facility')]")
  @browser.type_keys("xpath=//label[text()='Expected delivery facility']/../input", "\t")
  @browser.wait_for_ajax
end
