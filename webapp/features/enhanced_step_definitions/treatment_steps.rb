Given /^these treatments exist:$/ do |table|
  table.hashes.each do |attr|
    unless Treatment.exists?(['treatment_name = ?', attr['treatment_name']])
      Factory.create(:treatment, attr)
    end
  end
end

Given /^the disease "([^\"]*)" has the following treatments:$/ do |disease_name, table|
  @disease = Disease.find_by_disease_name(disease_name)
  @disease.treatments.clear
  table.hashes.each do |attr|
    @disease.treatments << Treatment.find_by_treatment_name(attr['treatment_name'])
  end
end

Then /^I should see the following associated treatments:$/ do |table|
  table.hashes.each do |attr|
    treatment = Treatment.find_by_treatment_name(attr['treatment_name'])
    @browser.is_element_present(<<-CSS.strip).should be_true
      css=#associated_treatments a[href='/trisano/treatments/#{treatment.id}']
    CSS
  end
end

