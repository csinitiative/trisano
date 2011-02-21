Then /^I should see help text for all (.*) event core fields$/ do |type|
  doc = Nokogiri::HTML(response.body)
  core_fields = CoreField.event_fields("#{type}_event").values.each do |core_field|
    next if core_field.disease_specific or core_field.container?
    doc.css("span#core_help_text_#{core_field.id}").should_not be_empty
  end
end

Then /^I should see all the core fields$/ do
  doc = Nokogiri::HTML(response.body)
  CoreField.all(:conditions => ['field_type != ?', 'event']).each do |cf|
    doc.xpath("//a[text()='#{cf.name}']").should_not be_empty
  end
end

Given /^a disease specific core field$/i do
  @core_field = Factory.create(:cmr_core_field, :disease_specific => true)
end
