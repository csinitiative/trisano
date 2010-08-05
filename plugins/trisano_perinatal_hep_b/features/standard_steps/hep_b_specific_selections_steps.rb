Given /^the hep b disease specific selections are loaded$/ do
  DiseaseSpecificSelection.create_perinatal_hep_b_associations
end

Then /^I should see only these (.+) select options:$/ do |select_id, options|
  id_regex = Regexp.new(select_id.downcase.gsub(/ +/, '_'))
  options.hashes.each_cons(2) do |this_tag, next_tag|
    assert_tag 'option', {
      :parent => {
        :tag => 'select',
        :attributes => {
          :id => id_regex
        }
      },
      :before => { :tag => 'option' }.merge(next_tag)
    }.merge(this_tag)
  end
  assert_tag 'select', {
    :attributes => { :id => id_regex },
    :children => { :count => options.rows.size }
  }
end



