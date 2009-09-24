Given /^the disease "([^\"]*)" exports to CDC when state is "([^\"]*)"$/ do |disease_name, case_description|
  disease = Disease.find_by_disease_name disease_name
  disease.external_codes << ExternalCode.case.find_by_code_description(case_description)
end

Given /^I have an active disease named "([^\"]*)"$/ do |disease_name|
  @disease = Factory.create(:disease, :disease_name => disease_name)
end

Given /^the following active diseases:$/ do |table|
  table.map_headers! 'Disease name' => :disease_name
  table.hashes.each do |attr|
    Disease.create! attr.merge(:active => true)
  end
end

Given /^the disease "([^\"]*)" is exported when "([^\"]*)"$/ do |disease_name, status|
  disease = Disease.find_by_disease_name disease_name
  disease.external_codes << ExternalCode.case.find_by_code_description(status)
  disease.save!
end
