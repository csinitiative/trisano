Given /^the hep b disease specific selections are loaded$/ do
  DiseaseSpecificSelection.create_perinatal_hep_b_associations
end

Then /^I should see only these contact disposition select options:$/ do |options|
  options.hashes.each do |option_hash|
    assert_tag 'select', {
      :attributes => { :id => /disposition/ },
      :child => { :tag => 'option' }.merge(option_hash),
    }
  end
  assert_tag 'select', {
    :attributes => { :id => /disposition/ },
    :children => { :count => options.rows.size }
  }
end



