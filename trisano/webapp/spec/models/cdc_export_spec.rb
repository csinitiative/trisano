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
  fixtures :diseases, :diseases_external_codes, :export_columns, :export_conversion_values

  def with_cdc_records(event_hash = @event_hash)
    event = MorbidityEvent.new(event_hash)
    event.save!
    event.reload
    records =  CdcExport.weekly_cdc_export.collect {|record| [record, event]}
    records.should_not be_empty
    yield records if block_given?
  end

  def with_sent_events(event_hash = @event_hash)
    events = []
    with_cdc_records do |records|
      samples = records.collect {|record| record[0]}
      CdcExport.reset_sent_status(samples)
      CdcExport.weekly_cdc_export.should be_empty
      events = samples.collect {|sample| Event.find(sample.event_id)}
    end
    yield events if block_given?
  end

  def delete_a_record(event_hash = @event_hash)
    with_sent_events do |events|
      @event_hash['disease']['disease_id'] = diseases(:chicken_pox).id
      events[0].update_attributes(@event_hash)
    end
    
  end
    

  before :each do
    @event_hash = {
      "imported_from_id" => external_codes(:imported_from_utah).id,
      "udoh_case_status_id" => external_codes(:case_status_probable).id,
      "disease" => {
        "disease_id" => diseases(:aids).id
      },
      "active_patient" => {
        "address" => {
          "county_id" => external_codes(:county_salt_lake).id
        },
        "entity_type"=>"person",
        "race_ids" => [external_codes(:race_white).id],
        "person" => {
          "last_name"=>"Biel",
          "ethnicity_id" => external_codes(:ethnicity_non_hispanic).id,
          "birth_gender_id" => external_codes(:gender_female).id,
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

    it "should display 3 digit county code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[27..29].should == '035'
      end
    end

    it "should display an unknown county code as 999" do
      @event_hash["active_patient"].delete("address")
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
      @event_hash['active_patient']['person']['birth_gender_id'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[42...43].should == 'U'
      end
    end

    it "should display sex as a single char code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[42...43].should == 'F'
      end
    end

    it "should display an unknown race as 'U'" do
      @event_hash['active_patient']['race_ids'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == 'U'
      end
    end

    it "should display race as a 1 digit code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == 'W'
      end
    end        

    it "should displat an unknown ethinicity as 'U'" do
      @event_hash['active_patient']['person']['ethnicity_id'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[44...45].should == 'U'
      end
    end

    it "should display ethnicity as a 1 char code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[44...45].should == 'N'
      end
    end

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
      with_cdc_records do |records|
        records[0].first.to_cdc[52...53].should == '2'
      end
    end

    it "should display imported as a one digit code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[53...54].should == '1'
      end
    end

    it "should display outbreak as a one digit code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[54...55].should == '0'
      end
    end

    describe 'resetting sent and updated flags' do
      it 'should mark an event a not updated and sent after processing' do
        with_cdc_records do |records|
          samples = records.collect {|record| record[0]}
          CdcExport.reset_sent_status(samples)
          event = records[0][1]
          event.reload
          event.should_not be_a_cdc_update
          event.should be_sent_to_cdc
        end
      end

      it 'should stop a record from appearing in the cdc export' do
        with_cdc_records do |records|
          samples = records.collect {|record| record[0]}
          CdcExport.reset_sent_status(samples)
          CdcExport.weekly_cdc_export.should be_empty
        end
      end
    end

    describe 'triggering the update flag' do

      it 'should update when imported from changes' do
        with_sent_events do |events|
          events.should_not be_empty
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes 'imported_from_id' => external_codes(:imported_from_unknown).id
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end
          
      it 'should update when disease changes' do
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({'disease' => {'disease_id' => diseases(:anthrax).id}})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when patient\'s county of residence changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({"active_patient" => {"address" => {"county_id" => external_codes(:county_salt_lake).id}}})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when race changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({"active_patient" => {"race_ids" => [external_codes(:race_black).id]}})
          events[0].save
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when birth gender changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({'active_patient' => {'person' => {'birth_gender_id' => external_codes(:gender_male).id}}})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when ethnicity changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({'active_patient' => {'person' => {'ethnicity_id' => external_codes(:ethnicity_hispanic).id}}})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when birth date changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({'active_patient' => {'person' => {'birth_date' => Date.parse('12/31/1975')}}})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end

      it 'should update when onset date changes' do
        pending
        with_sent_events do |events|
          events[0].should_not be_a_cdc_update
          events[0].should be_sent_to_cdc
          events[0].update_attributes({'event_onset_date' => Date.today - 1})
          events[0].should be_a_cdc_update
          events[0].should be_sent_to_cdc
        end
      end
    end
  end

  describe 'finding deleted cdc records' do
    
    before(:each)do
      delete_a_record 
      @deletes = CdcExport.weekly_cdc_deletes
    end

    it 'should return deleted records' do
      @deletes.length.should == 1
    end

    it "should return 'D' to represent deleted MMWR records" do
      @deletes[0].to_cdc[0...1].should == 'D'
    end

    it "should leave the update field blank" do
      @deletes[0].to_cdc[1...2].should == " "
    end

    it "should use '49' to represent Utah's state code" do
      @deletes[0].to_cdc[2..3].should == "49"
    end

    it "should report the last two digits of the mmwr year" do
      expected_date = Date.today.strftime('%y')
      @deletes[0].to_cdc[4..5].should == expected_date
    end

    it "should report the last 6 digits of the case id" do
      event = Event.find(@deletes[0].event_id)
      @deletes[0].to_cdc[6..11].should == event.record_number[-6, 6]
    end

    it "should report the 3 digit site code" do
      @deletes[0].to_cdc[12..14].should == 'S01'
    end

    it "should report the mmwr week" do
      event = Event.find(@deletes[0].event_id)
      @deletes[0].to_cdc[15..16].should == event.MMWR_week.to_s
    end

    it 'should cut off the filler' do
      @deletes[0].to_cdc.length.should == 17
    end
    
  end

  describe "displaying summary records for AIDS" do

    it "should display the summary record for AIDS" do 
      with_sent_events do
        CdcExport.verification_records.length.should == 1
      end
    end

    it "should display 'V' for the record type" do
      with_sent_events do
        CdcExport.verification_records[0].to_cdc[0...1].should == 'V'
      end
    end

    it "should display '49' for the state" do
      with_sent_events do
        CdcExport.verification_records[0].to_cdc[1..2].should == '49'
      end
    end

    it "should display '10560' for event code" do
      with_sent_events do
        CdcExport.verification_records[0].to_cdc[3..7].should == '10560'
      end
    end

    it "should display the counts of AIDS sent to CDC for the year" do
      with_sent_events do
        CdcExport.verification_records[0].to_cdc[8..12].should == '00001'
      end
    end

    it "should display the MMWR year as 2 digits" do
      year = Date.today.strftime('%y')
      with_sent_events do
        CdcExport.verification_records[0].to_cdc[13..14].should == year
      end
    end
  end

  describe "multiple verification records" do

    before :each do
      with_sent_events
      @event_hash['disease']['disease_id'] = diseases(:hep_a).id
      with_sent_events
      with_sent_events
    end
    
    it "should display two verification records" do
      CdcExport.verification_records.length.should == 2
    end

    it "should keep proper counts" do
      records = CdcExport.verification_records
      records.sort!{|a, b| a.count <=> b.count}
      records[0].to_cdc[8..12].should == '00001'
      records[1].to_cdc[8..12].should == '00002'
    end

  end

  describe "runnning export w/ no valid disease exports" do
    
    before :all do
    end

    it "should not blow up if there are no disease export statuses" do      
      ActiveRecord::Base.connection.execute('truncate table diseases_external_codes')
      CdcExport.verification_records
    end
  
  end

end
  
