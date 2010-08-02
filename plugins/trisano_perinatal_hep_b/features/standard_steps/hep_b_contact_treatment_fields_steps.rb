
Then /^I should not see the p\-hep\-b treatment fields$/ do
  response.should have_tag('#treatments') do
    with_tag('select[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]')
    with_tag('input[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_name]')
    without_tag('select[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]')
  end
end

Then /^I should see the p\-hep\-b treatment fields$/ do
  response.should have_tag('#treatments') do
    with_tag('select[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]')
    without_tag('input[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_name]')
    with_tag('select[name=?]', 'contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]')
  end
end

When /^I enter a valid treatment date of (.+) days ago$/ do |days|
  fill_in("contact_event[interested_party_attributes][treatments_attributes][0][treatment_date]", :with => (Date.today - days.to_i.days).to_s)
end

Then /^the treatment date of (.+) days ago should be visible in (.+) format$/ do |days, format|
  if format == "edit"
    response.body.should =~ /#{(Time.now - days.to_i.days).strftime("%B %d, %Y")}/m
  else
    response.body.should =~ /#{(Date.today - days.to_i.days).to_s}/m
  end
end