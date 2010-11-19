When /^I go to the diseases admin page$/ do
  @browser.open "/trisano/diseases"
end

Given /^these diseases exist:$/ do |table|
  table.hashes.each do |attr|
    unless Disease.exists?(['disease_name = ?', attr['disease_name']])
      Factory.create(:disease, attr)
    end
  end
end

When /^I follow the "([^\"]*)" disease Core Fields link$/ do |disease_name|
  @disease = Disease.find_by_disease_name(disease_name)
  @browser.click("css=a[href='/trisano/diseases/#{@disease.id}/core_fields']")
  @browser.wait_for_page_to_load
end
