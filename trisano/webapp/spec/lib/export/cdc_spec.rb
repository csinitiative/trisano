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
  fixtures :events, :participations, :disease_events, :diseases, :export_conversion_values, :export_columns, :diseases_export_columns

  before(:each) do
    @results = events(:cdc_answers_cmr)
    @results.extend(Export::Cdc::Record)

    # Hack alert: adding this through the fixtures breaks other specs
    # for reasons I can't fathom.
    DiseaseEvent.create(:disease_id => 5, :event_id => 4)
    question_id = Question.create(:question_text => 'hello?', :data_type => :single_line_text).id
    Answer.create(:question_id => question_id, :event_id => 4, :text_answer => '2006')
    Answer.create(:question_id => question_id, :event_id => 4, :export_conversion_value_id => 11, :text_answer => '2008')
    Answer.create(:question_id => question_id, :event_id => 4, :export_conversion_value_id => 11, :text_answer => '2007')
  end

  it 'should return the first vaccine year by id if duplicates' do
    @results.disease_specific_records.strip.should == '08'
  end

  describe 'writing the result' do
    include Export::Cdc::CdcWriter

    before :each do
      @result = ' ' * 10 + 'Beaver'
    end

    it 'should not shorten string when inserting values shorter then :length' do
      write('Utah', :starting => 0, :length => 10, :result => @result)
      @result.should == 'Utah      Beaver'
    end
  end

  describe 'converting values' do
    include Export::Cdc::CdcWriter

    before :each do      
      @conversion = mock(ExportConversionValue)
      @conversion.should_receive(:value_to).once.and_return 'error'
    end
    
    it 'should grab the right side of numbers (to get two digit years)' do      
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 2
      convert_value('2009', @conversion).should == '09'
    end

    it 'should ljust string values' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 4
      convert_value('Homer', @conversion).should == 'Home'
    end

    it 'should strip whitespace values' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 8
      convert_value('Homer', @conversion).should == 'Homer'
    end

    it 'should not rjust long postal codes' do
      @conversion.should_receive(:conversion_type).twice.and_return 'single_line_text'
      @conversion.should_receive(:length_to_output).once.and_return 5
      convert_value('46062-5888', @conversion).should == '46062'
    end

    it 'should not blow up on invalid dates' do
      @conversion.should_receive(:conversion_type).once.and_return 'date'
      value = ''
      lambda{value = convert_value('not-a-date', @conversion)}.should_not raise_error
      value.should == 'error'
    end

  end

  describe 'core path method calling' do    

    it 'should not blow up on broken configs' do
      mock_config = mock(FormElement)
      mock_config.should_receive(:call_chain).once.and_return([:not_a_method])
      value = ''
      lambda{value = MorbidityEvent.new.value_converted_using(mock_config)}.should_not raise_error
      value.should be_nil
    end
      
  end
end
