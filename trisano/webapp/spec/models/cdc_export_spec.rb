
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
require File.dirname(__FILE__) + '/../spec_helper'

describe CdcExport do
  fixtures :diseases, :diseases_external_codes, :export_conversion_values

  def with_cdc_records(event_hash = @event_hash)
    event = MorbidityEvent.new(event_hash)
    event.save!
    event.reload
    records =  CdcExport.weekly_cdc_export.collect {|record| [record, event]}
    yield records if block_given?
  end

  before :each do
    @event_hash = {
      "udoh_case_status_id" => external_codes(:case_status_probable).id,
      "disease" => {
        "disease_id" => diseases(:aids).id
      },
      "active_patient" => {
        "entity_type"=>"person", 
        "person" => {
          "last_name"=>"Biel",
          "birth_date" => Date.parse('01/01/1975')
        }          
      }
    }
  end
    
  describe 'running cdc export' do
    it 'should return records for mmr week' do
      with_cdc_records do |records|
        records.should_not be_nil
        records.length.should == 1
      end
    end
    
    it 'should use "M" to represent MMWR records' do
      with_cdc_records do |records|
        records[0].first.to_cdc[0...1].should == "M"
      end
    end

    it 'should leave a blank for the update field' do
      with_cdc_records do |records|
        records[0].first.to_cdc[1...2].should == " "
      end
    end

    it "should display '49' (state id) for the state field" do
      with_cdc_records do |records|
        records[0].first.to_cdc[2..3].should == "49"
      end
    end

    it "should display the last 2 digits of the mmwr year" do
      with_cdc_records do |records|
        expected_date = Date.today.strftime('%y')
        records[0].first.to_cdc[4..5].should == expected_date
      end
    end

    it "should display the last 6 digits of the case record number" do
      with_cdc_records do |records|
        records[0][0].to_cdc[6..11].should == records[0][1].record_number[-6, 6]
      end
    end

    it "should display the 3 digit site code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[12..14].should == 'S01'
      end
    end

    it "should display the MMWR week as 2 digits" do
      with_cdc_records do |records|
        records[0].first.to_cdc[15..16].should == records[0][1].MMWR_week.to_s
      end
    end

    it "should display the 5 digit disease code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[17..21].should == '10560'
      end
    end
    
    it "should display '00001' since this is always a single record" do
      with_cdc_records do |records|
        records[0].first.to_cdc[22..26].should == '00001'
      end
    end

    it "should display 3 digit county code"

    it "should display an unknown county code as 999" do
      with_cdc_records do |records|
        records[0].first.to_cdc[27..29].should == '999'
      end
    end

    it "should display birthday as YYYYMMDD" do
      with_cdc_records do |records|
        records[0].first.to_cdc[30..37].should == '19750101'
      end
    end

    it "should display an unknown birthday as 99999999" do
      @event_hash['active_patient']['person']['birth_date'] = nil      
      with_cdc_records do |records|
        records[0].first.to_cdc[30..37].should == '99999999'
      end
    end

    it "should display age at onset as a 3 digit field" do
      with_cdc_records do |records|
        records[0].first.to_cdc[38..40].should == records[0][1].age_at_onset.to_s.rjust(3, '0')
      end
    end

    it "should display age type as 1 digit field" do
      with_cdc_records do |records|
        records[0].first.to_cdc[41...42].should == "0"
      end
    end

    it "should display sex as 'U' for unknown genders" do
      with_cdc_records do |records|
        records[0].first.to_cdc[42...43].should == 'U'
      end
    end

    it "should display sex as a 1 digit code" 

    it "should display an unknown race as 'U'" do
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == 'U'
      end
    end

    it "should display race as a 1 digit code"    

    it "should displat an unknown ethinicity as 'U'" do
      with_cdc_records do |records|
        records[0].first.to_cdc[44...45].should == 'U'
      end
    end

    it "should display ethnicity as a 1 digit code"

    it "should display event date a YYMMDD" do
      with_cdc_records do |records|
        records[0].first.to_cdc[45..50].should == Date.today.strftime("%y%m%d")
      end
    end

    it "should display which event date was used as a one digit code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[51...52].should == "1"
      end
    end

    it "should display case status as a one digit code" do
      pending
      with_cdc_records do |records|
        records[0].first.to_cdc[52...53].should == '2'
      end
    end

    it "should display imported as a one digit code"

    it "should display outbreak as a one digit code"

  end

end
  
