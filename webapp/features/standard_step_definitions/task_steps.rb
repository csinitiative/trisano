# -*- coding: utf-8 -*-
Then /^I should see the following tasks:$/ do |expected_tasks|
  columns = lambda do |e|
    [
     e.css('th:nth-child(1) a', 'td:nth-child(1)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(2) a', 'td:nth-child(2)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(3) a', 'td:nth-child(3)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(4) a', 'td:nth-child(4)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(5) a', 'td:nth-child(5)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(6) a', 'td:nth-child(6)').text.gsub("\302\240", ' ').strip,
     e.css('th:nth-child(7) a', 'option[selected]').text.gsub("\302\240", ' ').strip
    ]
  end
  html = tableish("#task-list tr", columns)
  # need a better way to check for today
  html[1][0] = 'Today' if Date.parse(html[1][0]) == Date.today
  expected_tasks.diff! html
end

Then /^I should not see any tasks$/ do
  response.should_not have_xpath("//table[@id='task-list']")
end
