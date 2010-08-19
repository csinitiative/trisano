Then /^I should see a clinical note from "([^\"]*)"$/ do |author_best_name|
  note_rows = Nokogiri::HTML(response.body).css('div#existing-notes table tr')
  clinical_note_rows = note_rows.each_slice(3).select do |user_row, note_type_row, note_body|
    note_type_row.css('.note-type').inner_html =~ /clinical/i
  end.flatten
  clinical_note_rows.size.should == 3
  clinical_note_rows.first.css('th').inner_html.should =~ /#{author_best_name}/
end
