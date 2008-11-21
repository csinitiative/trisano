# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'export/cdc' do
  fixtures :events, :disease_events, :diseases, :export_conversion_values, :export_columns, :diseases_export_columns

  before(:each) do
    @results = {
      'event_id' => 4
    }
    @results.extend(Export::Cdc::Record)

    # Hack alert: adding this through the fixtures breaks other specs
    # for reasons I can't fathom.
    DiseaseEvent.create(:disease_id => 5, :event_id => 4)
    question_id = Question.create(:question_text => 'hello?', :data_type => :single_line_text).id
    Answer.create(:question_id => question_id, :event_id => 4, :export_conversion_value_id => 11)
    Answer.create(:question_id => question_id, :event_id => 4, :text_answer => '2006')
    Answer.create(:question_id => question_id, :event_id => 4, :export_conversion_value_id => 11, :text_answer => '2008')
    Answer.create(:question_id => question_id, :event_id => 4, :export_conversion_value_id => 11, :text_answer => '2007')
  end

  it 'should return the first vaccine year by id if duplicates' do
    @results.disease_specific_records.strip.should == '08'
  end

end
