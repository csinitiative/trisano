Given(/^a form exists with the name (.+) \((.+)\) for a (.+) with the disease (.+)$/) do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

When(/^I go to the Builder interface for the form$/) do
  @browser.click "link=FORMS"
  @browser.wait_for_page_to_load 30000
  click_build_form_by_id(@browser, @form.id)
end
