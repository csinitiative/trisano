Given /^the disease "([^\"]*)" with the cdc code "([^\"]*)"$/ do |disease_name, cdc_code|
  @disease = Disease.find_or_create_by_disease_name(:disease_name => disease_name, :cdc_code => cdc_code, :active => true)
end

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

Given /^the following organisms are associated with the disease "([^\"]*)":$/ do |disease_name, table|
  base_loinc = '1000-0'
  scale = ExternalCode.loinc_scales.find_by_the_code('Ord')
  disease = Disease.find_or_create_by_disease_name disease_name

  table.map_headers! 'Organism name' => :organism_name
  table.hashes.each do |attr|
    organism = Organism.create! attr
    loinc = LoincCode.create! :loinc_code => base_loinc = base_loinc.loinc_succ, :scale => scale, :organism => organism
    disease.loinc_codes << loinc
  end

  disease.save!
end

Given /^the following loinc codes are associated with the disease "([^\"]*)":$/ do |disease_name, table|
  disease = Disease.find_or_create_by_disease_name disease_name
  table.map_headers! 'Loinc code' => :loinc_code, 'Scale' => :scale
  table.hashes.each do |hash|
    attr = hash.dup
    attr[:scale] = ExternalCode.loinc_scales.find_by_the_code attr[:scale]
    loinc = LoincCode.find_or_create_by_loinc_code attr
    disease.loinc_codes << loinc
  end
  disease.save!
end
