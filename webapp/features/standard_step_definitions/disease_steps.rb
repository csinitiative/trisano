Given /^the disease "([^\"]*)" exports to CDC when state is "([^\"]*)"$/ do |disease_name, case_description|
  disease = Disease.find_by_disease_name disease_name
  disease.external_codes << ExternalCode.case.find_by_code_description(case_description)
end
