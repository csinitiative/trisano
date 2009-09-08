Given /^I have a loinc code "(.*)" with scale "(.*)"$/ do |loinc_code, scale|
  @scale = CodeName.loinc_scale.external_codes.find_by_code_description(scale)
  @loinc_code = LoincCode.create!(:loinc_code => loinc_code, :scale_id => @scale.id)
end

Given /^the loinc code has the organism "([^\"]*)"$/ do |organism_name|
  @loinc_code.organism = Organism.find_by_organism_name organism_name
  @loinc_code.save!
end

After('@clean_loinc_codes') do
  LoincCode.all.each(&:delete)
end
