# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

  def create_cdc_event
    event = MorbidityEvent.new(@event_hash)
    disease_event = DiseaseEvent.new(:disease_id => diseases(:aids).id, :disease_onset_date => Date.yesterday)
    event.save!
    event.build_disease_event(disease_event.attributes)
    event.save!
    event.reload
  end

  def with_cdc_records(event = nil)
    event = event || create_cdc_event

    start_mmwr = Mmwr.new(Date.today - 7)
    end_mmwr = Mmwr.new

    records =  CdcExport.weekly_cdc_export(start_mmwr, end_mmwr).collect {|record| [record, event]}
    yield records if block_given?
  end

  def with_sent_events(event = nil)
    records = []
    with_cdc_records(event) do |records|
      samples = records.collect {|record| record[0]}
      CdcExport.reset_sent_status(samples)
      IbisExport.reset_ibis_status(samples)
      start_mmwr = Mmwr.new(Date.today - 7)
      end_mmwr = Mmwr.new
      CdcExport.weekly_cdc_export(start_mmwr, end_mmwr).should_not be_empty
      # A little bit of indirection, cause the events returned from weekly_cdc_export are marked readonly by active-record.
      records = samples.collect { |sample| Event.find(sample.id) }
    end
    yield records if block_given?
  end

  def delete_a_record(event_hash = @event_hash)
    with_sent_events do |events|
      events[0].disease_event.disease_id = diseases(:chicken_pox).id
      events[0].save!
      events[0].reload
    end
  end

  def soft_delete_a_record(event_hash = @event_hash)
    with_sent_events do |events|
      event_hash['deleted_at'] = Date.today
      events[0].update_attributes(event_hash)
    end
  end

  before :each do
    SITE_CONFIG[RAILS_ENV] = {:cdc_state => "49"}
    @event_hash = {
      "first_reported_PH_date" => Date.yesterday.to_s(:db),
      "imported_from_id" => external_codes(:imported_from_utah).id,
      "state_case_status_id" => external_codes(:case_status_probable).id,
      "interested_party_attributes" => {
        "person_entity_attributes" => {
          "race_ids" => [external_codes(:race_white).id],
          "person_attributes" => {
            "last_name"=>"Biel",
            "ethnicity_id" => external_codes(:ethnicity_non_hispanic).id,
            "birth_gender_id" => external_codes(:gender_female).id,
            "birth_date" => Date.parse('01/01/1975')
          }
        }
      },
      "jurisdiction_attributes" => {
        "secondary_entity_id" => '75'
      },
      "address_attributes" => {
        "county_id" => external_codes(:county_salt_lake).id
      }
    }
  end

  describe 'running cdc export' do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    it 'should produce core data records (no disease specific fields) that are 60 chars long' do
      with_cdc_records do |records|
        records.collect {|record, event| record}.each do |record|
          record.to_cdc.length.should == 60
        end
      end
    end

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
        expected_date = Mmwr.new.mmwr_year.to_s[2..3]
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
        padded_week = records[0][1].MMWR_week < 10 ? records[0][1].MMWR_week.to_s.rjust(2, '0') : records[0][1].MMWR_week.to_s
        records[0].first.to_cdc[15..16].should == padded_week
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
      @event_hash.delete("address_attributes")
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
      @event_hash['interested_party_attributes']['person_entity_attributes']['person_attributes']['birth_date'] = nil
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

    it "should display sex as '9' for unknown genders" do
      @event_hash['interested_party_attributes']['person_entity_attributes']['person_attributes']['birth_gender_id'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[42...43].should == '9'
      end
    end

    it "should display female as '2'" do
      with_cdc_records do |records|
        records[0][0].to_cdc[42...43].should == '2'
      end
    end

    it "should display an unknown race as '9'" do
      @event_hash['interested_party_attributes']['person_entity_attributes']['race_ids'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == '9'
      end
    end

    it "should display race as a 1 digit code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == '5'
      end
    end

    it "should display an unknown ethinicity as '9'" do
      @event_hash['interested_party_attributes']['person_entity_attributes']['person_attributes']['ethnicity_id'] = nil
      with_cdc_records do |records|
        records[0].first.to_cdc[44...45].should == '9'
      end
    end

    it "should display ethnicity as a 1 char code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[44...45].should == '2'
      end
    end


    describe "event date calculations" do
      # This test is based on https://wiki.csinitiative.com/display/tri/Event+Onset+Date
      # It also checks to make sure that HumanEvent#set_onset_date remains in sync with
      # the CDC export's calculation of event onset date,
      # which is why there are two checks for each test as well as
      # the explict calls to .save (which triggers #set_onset_date)
      # when updating associated labs or disease_events
      context "when disease onset date is present" do

        before do
          @event_date_calculation_test = create_cdc_event
          @disease_onset_date = 10.days.ago.to_date
          @event_date_calculation_test.disease_event.update_attributes(:disease_onset_date => @disease_onset_date)
          @event_date_calculation_test.save!
        end

        it "should use disease onset date" do
          with_cdc_records @event_date_calculation_test do |records|
            records[0].first.to_cdc[45..50].should == @disease_onset_date.strftime("%y%m%d")
            HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @disease_onset_date.strftime("%y%m%d")
          end
        end
      end
      context "when disease onset date is nil" do
        before do
          @event_date_calculation_test = create_cdc_event
          @event_date_calculation_test.disease_event.update_attributes(:disease_onset_date => nil)
          @event_date_calculation_test.save!
        end

        context "and date diagnosed is present" do
          before do
            @date_diagnosed = 11.days.ago.to_date
            @event_date_calculation_test.disease_event.update_attributes(:date_diagnosed => @date_diagnosed)
            @event_date_calculation_test.save!
          end
          it "should use date diagnosed" do
            with_cdc_records @event_date_calculation_test do |records|
              records[0].first.to_cdc[45..50].should == @date_diagnosed.strftime("%y%m%d")
              HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @date_diagnosed.strftime("%y%m%d")
            end #with_cdc_records
          end #should use date diagnosed
        end #contxt date diagnosed is present

        context "and date diagnosed is nil" do

          before do
            @event_date_calculation_test.disease_event.update_attributes(:date_diagnosed => nil)
            @event_date_calculation_test.save!
          end

          context "and multiple lab collection dates are present" do
            before do
              @later_lab_collection_date = 14.days.ago.to_date
              @earliest_lab_collection_date = 15.days.ago.to_date
              lab = Factory(:lab)
              lab.lab_results.first.update_attributes(:collection_date => @earliest_lab_collection_date)
              lab.lab_results << Factory(:lab_result, :collection_date => @later_lab_collection_date)
              @event_date_calculation_test.labs << lab
              @event_date_calculation_test.save!
            end
            it "should use the earliest lab collection date" do
              with_cdc_records @event_date_calculation_test do |records|
                records[0].first.to_cdc[45..50].should == @earliest_lab_collection_date.strftime("%y%m%d")
                HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @earliest_lab_collection_date.strftime("%y%m%d")
              end #with_cdc_records
            end #should use earliest lab collection

            context "and multiple lab test dates are present, which are before the collection dates" do
              # This is to test specifically that the lab collection dates are given priority
              # over the test dates, even if the test dates are earlier
              before do
                @later_lab_test_date = 12.days.ago.to_date
                @earliest_lab_test_date = 13.days.ago.to_date
                lab = Factory(:lab)
                lab.lab_results.first.update_attributes(:lab_test_date => @earliest_lab_test_date)
                lab.lab_results << Factory(:lab_result, :lab_test_date => @later_lab_test_date)
                @event_date_calculation_test.labs << lab
                @event_date_calculation_test.save!
              end
              it "should use the earliest lab collection date" do
                with_cdc_records @event_date_calculation_test do |records|
                  records[0].first.to_cdc[45..50].should == @earliest_lab_collection_date.strftime("%y%m%d")
                  HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @earliest_lab_collection_date.strftime("%y%m%d")
                end #with_cdc_records
              end #should use earliest lab collection date
            end #context multiple lab test dates present
          end #context multiple lab collection dates present

          context "and lab collection dates are nil" do

            before do
              @event_date_calculation_test.labs.clear
            end

            context "and multiple lab test dates are present" do
              before do
                @earliest_lab_test_date = 9.days.ago.to_date
                @later_lab_test_date = 8.days.ago.to_date
                lab = Factory(:lab)
                lab.lab_results.first.update_attributes(:lab_test_date => @earliest_lab_test_date)
                lab.lab_results << Factory(:lab_result, :lab_test_date => @later_lab_test_date)
                @event_date_calculation_test.labs << lab
                @event_date_calculation_test.save!
              end
              it "should use the earliest lab test date" do
                with_cdc_records @event_date_calculation_test do |records|
                  records[0].first.to_cdc[45..50].should == @earliest_lab_test_date.strftime("%y%m%d")
                  HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @earliest_lab_test_date.strftime("%y%m%d")
                end #with_cdc_records
              end #should use earliest lab test date
            end #context multiple lab test dates present

            context "and lab test dates are nil" do

              before do
                @event_date_calculation_test.labs.clear
              end

              context "date first reported to public health is present" do
                before do
                  @date_first_reported_to_public_health = 16.days.ago.to_date
                  @event_date_calculation_test.update_attributes(:first_reported_PH_date => @date_first_reported_to_public_health)
                end
                it "should use date first reported to public health" do
                  with_cdc_records @event_date_calculation_test do |records|
                    records[0].first.to_cdc[45..50].should == @date_first_reported_to_public_health.strftime("%y%m%d")
                    HumanEvent.find(records[0].first.id).event_onset_date.strftime("%y%m%d").should == @date_first_reported_to_public_health.strftime("%y%m%d")
                  end #with cdc_records
                end #should use date first reported to public health
              end #context date first reported to public health is present

              context "date first reported to public health is nil" do

                before do
                  # Here, we have a validation that prevents this type of action,
                  # however, it's possible that data like this could be present
                  # so we want to test this case by not running validations
                  # by using #update_attribute
                  @event_date_calculation_test.update_attribute(:first_reported_PH_date, nil)
                end

                context "date event created is present" do
                  before do
                    @date_created = 17.days.ago.to_date
                    @event_date_calculation_test.suppress_validation(:first_reported_PH_date)
                    @event_date_calculation_test.update_attribute(:created_at, @date_created)
                    @event_date_calculation_test.save!
                  end
                  it "should use date created" do
                    with_cdc_records @event_date_calculation_test do |records|
                      HumanEvent.find(records[0].first.id).send(:resolve_onset_date).strftime("%y%m%d").should == @date_created.strftime("%y%m%d")

                      records[0].first.to_cdc[45..50].should == @date_created.strftime("%y%m%d")

                      # we cheat here, because we're forcing invalid data into the model
                      # we must access a private method in order to verify it calculates correctly
                    end #with_cdc_records
                  end #should use date created
                end #date event created is present

                context "when event date created is nil" do
                  it "should use 999999" do

                    #this case is here for documentation purposes.
                    #the system should never be able to have an event without created_at
                    #additionally, a CDC export could never include an event with out a created_at because
                    #it's used for the MMRW calculations

                  end #should ouput 999999
                end #context event date created is nil
              end #context date first reported to public health is nil
            end #context lab test dates are nil
          end #context lab colelction dates are nil
        end #context date diagnosed is nil
      end #context disease date is nil
    end #event edate calculations

    it "should display which event date was used as a one digit code" do
      with_cdc_records do |records|
        records[0].first.to_cdc[51...52].should == "1"
      end
    end

     it "should display events for this year only for weekly report" do
      event = create_cdc_event
      event.disease_event.disease_onset_date = Date.new(Date.today.year - 1, 12, 31)
      event.cdc_updated_at = Date.today
      event.save!
      event.reload

      new_event = create_cdc_event
      new_event.disease_event.disease_onset_date = Date.new(Date.today.year, 5, 15)
      new_event.cdc_updated_at = Date.today
      new_event.save!
      new_event.reload

      start_mmwr = Mmwr.new(Date.today - 7)
      end_mmwr = Mmwr.new

      records =  CdcExport.weekly_cdc_export(start_mmwr, end_mmwr)
      records.find {|e| e.id == event.id}.should == nil
      records.find {|e| e.id == new_event.id}.should_not == nil
     end

     it "should correctly display events for a week spanning two years" do
      event = create_cdc_event
      event.disease_event.disease_onset_date = Date.parse("2011/12/31")
      event.save!
      event.reload

      start_mmwr = Mmwr.new(Date.parse("2012/01/01") - 7)
      end_mmwr = Mmwr.new(Date.parse("2012/01/01"))

      records =  CdcExport.weekly_cdc_export(start_mmwr, end_mmwr)
      records.first.id.should == event.id
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
        records[0][0].to_cdc[54...55].should == '9'
      end
    end

    describe 'resetting sent and updated flags' do
      it 'should mark an event sent after processing' do
        with_cdc_records do |records|
          samples = records.collect {|record| record[0]}
          CdcExport.reset_sent_status(samples)
          IbisExport.reset_ibis_status(samples)
          event = records[0][1]
          event.reload
          event.should be_sent_to_cdc
          event.should be_sent_to_ibis
        end
      end

      it 'should not stop a record from appearing in the cdc export' do
        with_cdc_records do |records|
          samples = records.collect {|record| record[0]}
          CdcExport.reset_sent_status(samples)
          start_mmwr = Mmwr.new(Date.today - 7)
          end_mmwr = Mmwr.new
          CdcExport.weekly_cdc_export(start_mmwr, end_mmwr).should_not be_empty
        end
      end
    end

    describe 'triggering the update flag' do

      it 'should update when imported from changes' do
        with_sent_events do |events|
          events.should_not be_empty
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes 'imported_from_id' => external_codes(:imported_from_unknown).id
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when disease changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].disease_event.disease_id = diseases(:anthrax).id
          events[0].save!
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when patient\'s county of residence changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes!("address_attributes" => {"county_id" => external_codes(:county_summit).id})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when race changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes!({"interested_party_attributes" => {"person_entity_attributes" => {"race_ids" => [external_codes(:race_black).id], 'person_attributes' => {'last_name' => 'Someone'}}}})
          events[0].save!
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when birth gender changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes!({'interested_party_attributes' => {'person_entity_attributes' => {'person_attributes' => {'birth_gender_id' => external_codes(:gender_male).id, 'last_name' => 'Someone'}}}})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when ethnicity changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes!({'interested_party_attributes' => {'person_entity_attributes' => {'person_attributes' => {'ethnicity_id' => external_codes(:ethnicity_hispanic).id, 'last_name' => 'Someone'}}}})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when birth date changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes!({'interested_party_attributes' => {'person_entity_attributes' => {'person_attributes' => {'birth_date' => Date.parse('12/31/1975'), 'last_name' => 'Someone'}}}})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when onset date changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes({'event_onset_date' => Date.today - 1})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when deleted_at changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes({:deleted_at => Date.today})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should update when state status changes' do
        with_sent_events do |events|
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
          events[0].ibis_updated_at.should be_nil
          events[0].update_attributes({:state_case_status_id => external_codes(:case_status_confirmed).id})
          events[0].cdc_updated_at.should == Date.today
          events[0].ibis_updated_at.should == Date.today
          events[0].should be_sent_to_cdc
          events[0].should be_sent_to_ibis
        end
      end

      it 'should set cdc update at date when state status changes, even if not sent' do
        morb = Factory.create :morbidity_event
        morb.should_not be_sent_to_cdc

        test_date = DateTime.new(2007, 8, 9)
        morb.cdc_updated_at = test_date
        morb.update_attribute(:state_case_status_id, external_codes(:case_status_confirmed).id)
        morb.cdc_updated_at.should_not == test_date
      end

    end
  end

  describe 'finding deleted cdc records' do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    before(:each)do
      delete_a_record
      start_mmwr = Mmwr.new(Date.today - 7)
      end_mmwr = Mmwr.new
      @deletes = CdcExport.cdc_deletes(start_mmwr, end_mmwr)
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
      expected_date = Mmwr.new.mmwr_year.to_s[2..3]
      @deletes[0].to_cdc[4..5].should == expected_date
    end

    it "should report the last 6 digits of the case id" do
      @deletes[0].to_cdc[6..11].should == @deletes[0].record_number[-6, 6]
    end

    it "should report the 3 digit site code" do
      @deletes[0].to_cdc[12..14].should == 'S01'
    end

    it "should report the mmwr week" do
      padded_week = @deletes[0].MMWR_week < 10 ? @deletes[0].MMWR_week.to_s.rjust(2, '0') : @deletes[0].MMWR_week.to_s
      @deletes[0].to_cdc[15..16].should == padded_week
    end

    it 'should cut off the filler' do
      @deletes[0].to_cdc.length.should == 17
    end

  end

  describe 'soft deleted records' do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    describe 'that have already been sent' do

      it 'should appear in the cdc export as deleted records' do
        soft_delete_a_record
        start_mmwr = Mmwr.new(Date.today - 7)
        end_mmwr = Mmwr.new
        CdcExport.cdc_deletes(start_mmwr, end_mmwr).length.should == 1
      end

      it 'should not appear in verification records' do
        soft_delete_a_record
        CdcExport.verification_records(Mmwr.new.mmwr_year).should be_empty
      end

      it 'should not generate an update record' do
        with_cdc_records(@event_hash.merge(:deleted_at => Date.today)) do |records|
          records.size.should == 0
        end
      end
    end

  end

  describe "displaying summary records for AIDS" do
    fixtures :events, :disease_events, :diseases

    it "should display the summary record for AIDS" do
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year).length.should == 1
      end
    end

    it "should display 'V' for the record type" do
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[0...1].should == 'V'
      end
    end

    it "should display '49' for the state" do
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[1..2].should == '49'
      end
    end

    it "should display '10560' for event code" do
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[3..7].should == '10560'
      end
    end

    it "should display the counts of AIDS sent to CDC for the year" do
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[8..12].should == '00001'
      end
    end

    it "should display the MMWR year as 2 digits" do
      year = Mmwr.new.mmwr_year.to_s[2..3]
      with_sent_events do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[13..14].should == year
      end
    end
  end

  describe "multiple verification records" do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    before :each do
      with_sent_events
      2.times {
        event = MorbidityEvent.new(@event_hash)
        disease_event = DiseaseEvent.new(:disease_id => diseases(:hep_a).id, :disease_onset_date => Date.yesterday)
        event.save!
        event.build_disease_event(disease_event.attributes)
        event.save!
        event.reload
        with_sent_events(event)
      }
    end

    it "should display two verification records" do
      CdcExport.verification_records(Mmwr.new.mmwr_year).length.should == 2
    end

    it "should keep proper counts" do
      records = CdcExport.verification_records(Mmwr.new.mmwr_year)
      records.sort!{|a, b| a.count <=> b.count}
      records[0].to_cdc[8..12].should == '00001'
      records[1].to_cdc[8..12].should == '00002'
    end

  end

  describe "runnning export w/ no valid disease exports" do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    before :all do
    end

    it "should not blow up if there are no disease export statuses" do
      ActiveRecord::Base.connection.execute('truncate table cdc_disease_export_statuses')
      CdcExport.verification_records(Mmwr.new.mmwr_year)
    end
  end

  describe 'displaying verification records' do
    fixtures :diseases, :external_codes

    it 'should show no results' do
      CdcExport.verification_records(Mmwr.new.mmwr_year).should be_empty
    end

    describe 'with one morb event' do
      before :each do
        @morbidity_event = Factory.build :morbidity_event_with_disease
        @morbidity_event.state_case_status_id = external_codes(:case_status_probable).id
        @morbidity_event.save!

        disease = @morbidity_event.disease_event.disease
        disease.cdc_disease_export_statuses << external_codes(:case_status_probable)
        disease.cdc_disease_export_statuses << external_codes(:case_status_confirmed)
        disease.save!
      end

      it 'should show one verification record' do
        CdcExport.verification_records(Mmwr.new.mmwr_year).size.should == 1
      end

      it 'should count one event' do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[8..12].should == '00001'
      end

      describe 'and one contact event' do
        before :each do
          @contact_event = Factory.build :contact_event
          @contact_event.save!
          disease_event = DiseaseEvent.new(:disease_id => @morbidity_event.disease_event.disease_id)
          @contact_event.build_disease_event(disease_event.attributes)
          @contact_event.reload
          @contact_event.MMWR_year = Mmwr.new.mmwr_year
          @contact_event.state_case_status_id = external_codes(:case_status_probable).id
          @contact_event.save!
        end

        it 'should show one verification record' do
          CdcExport.verification_records(Mmwr.new.mmwr_year).size.should == 1
        end

        it 'should not count the Contact event' do
          CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[8..12].should == '00001'
        end
      end
    end

    describe 'with two events, each w/ a different state status' do
      before :each do
        @probable_event = Factory.build :morbidity_event_with_disease
        @probable_event.state_case_status_id = external_codes(:case_status_probable).id
        @probable_event.save!

        disease = @probable_event.disease_event.disease
        disease.cdc_disease_export_statuses << external_codes(:case_status_probable)
        disease.cdc_disease_export_statuses << external_codes(:case_status_confirmed)
        disease.save!

        @confirmed_event = Factory.build :morbidity_event
        @confirmed_event.state_case_status_id = external_codes(:case_status_confirmed).id
        @confirmed_event.workflow_state = 'assigned_to_lhd'
        @confirmed_event.save!
        disease_event = DiseaseEvent.new(:disease_id => @probable_event.disease_event.disease_id)
        @confirmed_event.build_disease_event(disease_event.attributes)
        @confirmed_event.save!
        @confirmed_event.reload
      end

      it 'should show one verification record' do
        CdcExport.verification_records(Mmwr.new.mmwr_year).size.should == 1
      end

      it 'should count one event' do
        CdcExport.verification_records(Mmwr.new.mmwr_year)[0].to_cdc[8..12].should == '00002'
      end

    end

  end

  describe 'weekly cdc export' do
    fixtures :diseases, :external_codes

    before :each do
      @morb = Factory(:morbidity_event_with_disease)
      @morb.disease_event.disease_onset_date = Mmwr.week(8, :for_year => 2009).mmwr_week_range.start_date
      @morb.state_case_status_id = external_codes(:case_status_confirmed).id
      @morb.save!

      @disease = @morb.disease_event.disease
      @disease.cdc_disease_export_statuses << external_codes(:case_status_confirmed)
      @disease.active = true
      @disease.save!

      # fix the cdc_updated_at date so these tests stay valid
      MorbidityEvent.update_all("cdc_updated_at='2009-7-28'", "id=#{@morb.id}")
      @mmwr = Mmwr.new(Date.parse('July 28, 2009'))
      @mmwr_year = @mmwr.mmwr_year
    end

    it 'should show a valid export event on its mmwr week' do
      result = CdcExport.weekly_cdc_export(Mmwr.week(7, :for_year => @mmwr_year), Mmwr.week(8, :for_year => @mmwr_year))
      result.size.should == 1
      result[0].exp_event.should == @disease.cdc_code
    end

    it 'should show a valid export event on in a week it was cdc updated' do
      result = CdcExport.weekly_cdc_export(@mmwr, (@mmwr + 1.week))
      result.size.should == 1
      result[0].exp_event.should == @disease.cdc_code
    end

    it 'should not show a valid export event updated this year, if the mmwr year is more then one year old' do
      @morb.disease_event.disease_onset_date = Mmwr.week(8, :for_year => @mmwr_year - 2).mmwr_week_range.start_date
      @morb.save!
      result = CdcExport.weekly_cdc_export(@mmwr, (@mmwr + 1.week))
      result.should == []
    end

    it 'should not show up in other weekly queries' do
      result = CdcExport.weekly_cdc_export((@mmwr + 1.week), (@mmwr + 2.weeks))
      result.should be_empty
    end

    it 'should include all entries with mmwr week between end values (inclusive)' do
      result = CdcExport.weekly_cdc_export Mmwr.week(7, :for_year => @mmwr_year), Mmwr.week(9, :for_year => @mmwr_year)
      result.should_not be_empty
    end
  end

end