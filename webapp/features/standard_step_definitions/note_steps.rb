# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.
Then /^I should see a clinical note from "([^\"]*)"$/ do |author_best_name|
  note_rows = Nokogiri::HTML(response.body).css('div#existing-notes table tr')
  clinical_note_rows = note_rows.each_slice(3).select do |user_row, note_type_row, note_body|
    note_type_row.css('.note-type').inner_html =~ /clinical/i
  end.flatten
  clinical_note_rows.size.should == 3
  clinical_note_rows.first.css('th').inner_html.should =~ /#{author_best_name}/
end
