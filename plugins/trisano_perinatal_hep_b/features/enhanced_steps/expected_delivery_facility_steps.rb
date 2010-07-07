Then /^I should see the expected delivery facility fields$/ do
  assert(@browser.element?('css=#disease_info_form .form #expected_delivery_facility'))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='vert']/label[text()='Expected delivery facility']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Area code']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Phone number']/../input"))
  assert(@browser.element?("xpath=//*[@id='expected_delivery_facility']/*[@class='horiz']/label[text()='Extension']/../input"))
end

When /^I complete the expected delivery facility fields$/ do
  @browser.type("xpath=//label[text()='Expected delivery facility']/../input", "New Expected Delivery Facility")
  @browser.type("xpath=//label[text()='Area code']/../input", '999')
  @browser.type("xpath=//label[text()='Phone number']/../input", "555-1234")
  @browser.type("xpath=//label[text()='Extension']/../input", '888')
end

When /^I save and continue$/ do
  @browser.click("//*[@id='save_and_continue_btn']")
  @browser.wait_for_page_to_load
end

Then /^I should see the deliver facility data$/ do
  assert(@browser.element?("xpath=//label[text()='Expected delivery facility']"))
  assert_match(/New Expected Delivery Facility/, @browser.get_text("xpath=//label[text() = 'Expected delivery facility']/.."))
  assert(@browser.element?("xpath=//label[text()='Area code']"))
  assert(@browser.element?("xpath=//label[text()='Phone number']"))
  assert(@browser.element?("xpath=//label[text()='Extension']"))
end
