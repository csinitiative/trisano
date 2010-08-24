Given /^disease "([^\"]*)" has the disease specific "([^\"]*)" options:$/ do |disease_name, code_name, new_options|
  @disease = disease!(disease_name)
  # code names are inconsistent, so this won't always work
  @code_name = CodeName.find_by_code_name(code_name.downcase.gsub(' ', ''))
  new_options.hashes.each do |code_attr|
    code = @code_name.external_codes.build(code_attr.merge(:disease_specific => true))
    code.save!
    @disease.disease_specific_selections.create(:external_code_id => code.id, :rendered => true)
  end
end

Given /^disease "([^\"]*)" hides these "([^\"]*)" options:$/ do |disease_name, code_name, new_options|
  @disease = disease!(disease_name)
  new_options.hashes.each do |code_attr|
    code = external_code!(code_name.downcase.gsub(' ', ''), code_attr['the_code'], code_attr)
    @disease.disease_specific_selections.create(:external_code_id => code.id, :rendered => false)
  end
end

Then /^I should see all of the default "([^\"]*)" options$/ do |code_name|
  @selections_cache = CodeSelectCache.new
  @selections = @selections_cache.drop_down_selections(code_name.gsub(' ', '').downcase)
  @selections.each do |selection|
    assert_tag(:tag => 'option',
               :content => selection.code_description,
               :parent => { :tag => 'select' })
  end
end
