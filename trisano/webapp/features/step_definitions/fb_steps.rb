
#
# Basic navigation
#

When /^I navigate to the new form view$/ do
  visit new_form_path
  response.should contain("Create Form")
end

When /^I navigate to the form builder interface$/ do
  visit builder_path(@form)
  response.should contain("Form Builder")
end

#
# Generic helpers
#

When /^I create a new form named (.+) \((.+)\) for a (.+) with the disease (.+)$/ do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

When /^I enter a form name of (.+)$/ do |form_name|
  fill_in "form_name", :with => form_name
end

When /^I enter a form short name of (.+)$/ do |form_short_name|
  fill_in "form_short_name", :with => form_short_name
end

When /^I select a form event type of (.+)$/ do |event_type|
  select event_type, :from => "form_event_type"
end

When /^I check the disease (.+)$/ do |disease|
  check disease
end

When /^I create the new form$/ do
  submit_form "form_submit"
end

Then /^I should be able to create the new form and see the form name (.+)$/ do |form_name|
  save_new_form(form_name)
end
