# -*- coding: utf-8 -*-
Then /^I should see the following tasks:$/ do |expected_tasks|
  t = table element_at("#task-list").to_table
  t.map_headers!(t.headers[0] => 'Due Date',
                 t.headers[1] => 'Name',
                 t.headers[2] => 'Description',
                 t.headers[3] => 'Category',
                 t.headers[4] => 'Priority',
                 t.headers[5] => 'Assigned to',
                 t.headers[6] => 'Status')
  t.headers.each do |column|
    t.map_column!(column) do |value|
      v = value.gsub([0xA0].pack('U'), ' ').gsub('&nbsp;', ' ').strip
      if v.blank?
        nil
      else
        v
      end
    end
  end
  t.map_column! 'Status' do |value|
    Nokogiri::HTML("<html>#{value}</html>").xpath("//option[@selected='selected']").text()
  end
  expected_tasks.map_column! 'Due Date' do |value|
    value.downcase == 'today' ? Date.today.to_s : value
  end

  expected_tasks.diff! t
end

Then /^I should not see any tasks$/ do
  response.should_not have_xpath("//table[@id='task-list']")
end
