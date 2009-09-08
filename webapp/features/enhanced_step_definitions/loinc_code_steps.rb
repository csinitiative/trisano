When /^I navigate to the loinc code "([^\"]*)" edit page$/ do |loinc_code|
  @browser.click "link=ADMIN"
  @browser.wait_for_page_to_load
  @browser.click "link=Manage LOINC Codes"
  @browser.wait_for_page_to_load
  @browser.click "link=#{loinc_code}"
  @browser.wait_for_page_to_load
  @browser.click "link=Edit"
  @browser.wait_for_page_to_load
end

Then /^the Organism field should be disabled$/ do
  @browser.is_editable('css=#loinc_code_organism_id').should be_false
end

Then /^the Organism field should be enabled$/ do
  @browser.is_editable('css=#loinc_code_organism_id').should be_true
end

