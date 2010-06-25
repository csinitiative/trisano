Then /^I should not see expected delivery fields$/ do
  response.should_not have_tag('legend', 'Expected Delivery Information')
end

Then /^I should see expected delivery fields$/ do
  response.should have_tag('legend', 'Expected Delivery Information')
end

Then /^I should see expected delivery data:$/ do |table|
  response.should have_tag('fieldset') do
    with_tag('legend', 'Expected Delivery Information')
    table.hashes.each do |hash|
      with_tag('span') do
        with_tag('label', hash['Field'])
        # not sure why should contain doesn't work. Had to use response
        response.should contain(hash['Value'])
      end
    end
  end
end
