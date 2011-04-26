def add_p_hep_b_treatment(treatment, days_ago, index_string="1st")
  index = index_string[0..1].to_i
  @browser.click("link=Add a Treatment") unless index == 1
  sleep(1)
  click_core_tab(@browser, CLINICAL)
  @browser.select("xpath=//div[@id='treatments']//li[@class='treatment'][#{index}]//select[contains(@name, 'yn')]", "Yes")
  @browser.select("xpath=//div[@id='treatments']//li[@class='treatment'][#{index}]//select[contains(@name, 'treatment_id')]", treatment)
  @browser.type("xpath=//div[@id='treatments']//li[@class='treatment'][#{index}]//input[contains(@name, 'treatment_date')]", (Date.today - days_ago.to_i.days).to_s)

end

When /^I add a p\-hep\-b treatment "([^\"]*)" on with a date (.+) days ago$/ do |treatment, days_ago|
  add_p_hep_b_treatment(treatment, days_ago)
end

When /^I add a (.+) p\-hep\-b treatment "([^\"]*)" on with a date (.+) days ago$/ do |index_string, treatment, days_ago|
  add_p_hep_b_treatment(treatment, days_ago, index_string)
end

Then /^I should see the treatment "([^\"]*)" on with a date (.+) days ago$/ do |treatment, days_ago|
  assert(@browser.get_html_source.include?(treatment))
  assert(@browser.get_html_source.include?((Date.today - days_ago.to_i.days).to_s))
end

When /^I remove the (.+) treatment$/ do |index_string|
  click_core_tab(@browser, CLINICAL)
  index = index_string[0..1].to_i
  @browser.check("xpath=//div[@id='treatments']//li[@class='treatment'][#{index}]//input[contains(@name, 'destroy')][2]")
end

Then /^I should not see the treatment "([^\"]*)" on with a date (.+) days ago$/ do |treatment, days_ago|
  assert(!@browser.get_html_source.include?(treatment))
  assert(!@browser.get_html_source.include?((Date.today - days_ago.to_i.days).to_s))
end
