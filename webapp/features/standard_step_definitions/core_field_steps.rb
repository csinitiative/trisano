Then /^I should see help text for all (.*) event core fields$/ do |type|
  doc = Nokogiri::HTML(response.body)
  core_fields = CoreField.event_fields("#{type}_event").values.each do |core_field|
    next if core_field.disease_specific or core_field.container? or core_field.repeater?
    doc.css("span#core_help_text_#{core_field.id}").should_not be_empty, core_field.inspect+" did not have help text assigned"
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

When /^I edit a (.*) event core field and add help text that says '(.*)'$/ do |event_type, help_text|
  core_field = CoreField.event_fields("#{event_type}_event").values.first
  visit edit_core_field_path(core_field)
  fill_in :core_field_help_text, :with => help_text
  click_button "Update"
end
