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

    diseases(:syphilis).export_columns.clear
    diseases(:syphilis).export_columns << [export_columns(:std_neuro),
                                           export_columns(:std_infosrce),
                                           export_columns(:std_detected)]
    diseases(:syphilis).avr_groups.clear
    diseases(:syphilis).avr_groups << AvrGroup.std

    disease_event = DiseaseEvent.new(:disease_id => diseases(:syphilis).id, :disease_onset_date => Date.yesterday)
    event.save!
    event.build_disease_event(disease_event.attributes)
    event.save!

    lab = Factory(:lab)
    lab.lab_results.first.update_attributes(
        :specimen_source => external_codes(:specimen_blood),
        :lab_test_date => 10.days.ago,
        :collection_date => 14.days.ago.to_date,
        :test_type => common_test_types(:rpr),
        :result_value => "1:64")
    lab.lab_results << Factory(:lab_result,
                               :specimen_source => external_codes(:specimen_tissue),
                               :lab_test_date => 11.days.ago,
                               :collection_date => 15.days.ago.to_date,
                               :test_type => common_test_types(:vdrl),
                               :result_value => "<64")
    event.labs << lab

    treatment = Treatment.find_or_create_by_treatment_name("TST")
    event.interested_party.treatments << ParticipationsTreatment.create!(:treatment => treatment, :treatment_date => 5.days.ago)
    event.interested_party.treatments << ParticipationsTreatment.create!(:treatment => treatment, :treatment_date => 1.days.ago)

    event.answers << Factory.build(:answer, :export_conversion_value => export_conversion_values(:neuro_confirmed))
    event.answers << Factory.build(:answer, :export_conversion_value => export_conversion_values(:detected_provider))
    event.answers << Factory.build(:answer, :export_conversion_value => export_conversion_values(:infosrce_hiv_counceling))
    event.save!
    event.reload
  end

  def with_cdc_records(event = nil)
    event = event || create_cdc_event

    start_mmwr = Mmwr.new(Date.today - 7)
    end_mmwr = Mmwr.new

    records = CdcExport.weekly_cdc_export(start_mmwr, end_mmwr).collect { |record| [record, event] }
    yield records if block_given?
  end

  before :each do
    SITE_CONFIG[RAILS_ENV] = {:cdc_state => "20"}
    AvrGroup.find_or_create_by_name("STD Data")

    @event_hash = {
        "first_reported_PH_date" => Date.yesterday.to_s(:db),
        "imported_from_id" => external_codes(:imported_from_utah).id,
        "state_case_status_id" => external_codes(:case_status_probable).id,
        "interested_party_attributes" => {
            "person_entity_attributes" => {
                "person_attributes" => {
                    "last_name"=>"Biel",
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

  describe 'test STD CdcRecord methods' do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :common_test_types, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    it 'should detect export events' do
      event = create_cdc_event
      event = HumanEvent.find(event.id)
      event.export?.should == false

      event = HumanEvent.find_by_sql("select 1 as export from events where id = #{event.id}").first
      event.export?.should == true
    end

    it 'should detect diseases in STD group for Kansas' do
      event = create_cdc_event
      event.kansas_and_std?.should == false
      event = HumanEvent.find_by_sql("select 1 as export, #{AvrGroup.std.id} as avr_group_ids from events where id = #{event.id}").first
      event.kansas_and_std?.should == true
    end
  end

  describe 'running cdc export' do
    fixtures :events, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types, :common_test_types

    it 'should produce core data records (no disease specific fields) that are 191 chars long' do
      with_cdc_records do |records|
        records.collect { |record, event| record }.each do |record|
          record.to_cdc.length.should == 191
        end
      end
    end

    it 'should return records for mmr week' do
      with_cdc_records do |records|
        records.should_not be_nil
        records.length.should == 1
      end
    end

    it 'should return first_reported_to_public_health_date' do
      with_cdc_records do |records|
        records[0].first.to_cdc[121...129].should == Date.yesterday.strftime("%Y%m%d")
      end
    end

    it 'should return neuro in disease specific answers' do
      with_cdc_records do |records|
        records[0].first.to_cdc[export_columns(:std_neuro).start_position - 1, export_columns(:std_neuro).length_to_output].should == export_conversion_values(:neuro_confirmed).value_to
      end
    end

    it 'should return infosrce in disease specific answers' do
      with_cdc_records do |records|
        records[0].first.to_cdc[export_columns(:std_infosrce).start_position - 1, export_columns(:std_infosrce).length_to_output].should == export_conversion_values(:infosrce_hiv_counceling).value_to
      end
    end

    it 'should return detected in disease specific answers' do
      with_cdc_records do |records|
        records[0].first.to_cdc[export_columns(:std_detected).start_position - 1, export_columns(:std_detected).length_to_output].should == export_conversion_values(:detected_provider).value_to
      end
    end

    it 'should return pregnant unknown' do
      with_cdc_records do |records|
        records[0].first.to_cdc[74...75].should == "9"
      end
    end

    it 'should return pregnant yes' do
      e = create_cdc_event
      e.interested_party.build_risk_factor(:pregnant => external_codes(:yesno_yes))
      e.save!

      with_cdc_records(e) do |records|
        records[0].first.to_cdc[74...75].should == "1"
      end
    end

    it 'should return pregnant no' do
      e = create_cdc_event
      e.interested_party.build_risk_factor(:pregnant => external_codes(:yesno_no))
      e.save!

      with_cdc_records(e) do |records|
        records[0].first.to_cdc[74...75].should == "2"
      end
    end

    it 'should return zip if present' do
      e = create_cdc_event
      e.build_address(:postal_code =>"90064")
      e.save!
      with_cdc_records(e) do |records|
        records[0].first.to_cdc[64...69].should == "90064"
      end
    end

    it 'should return zip as 99999 if not present' do
      with_cdc_records do |records|
        records[0].first.to_cdc[64...69].should == "99999"
      end
    end

    it 'should use "M" to represent MMWR records' do
      with_cdc_records do |records|
        records[0].first.to_cdc[0...1].should == "M"
      end
    end

    it 'should leave 9 for the update field' do
      with_cdc_records do |records|
        records[0].first.to_cdc[1...2].should == "9"
      end
    end

    it "should not raise errors for events with blank fields" do
      event = MorbidityEvent.new(@event_hash)
      disease_event = DiseaseEvent.new(:disease_id => diseases(:aids).id, :disease_onset_date => Date.yesterday)
      event.save!
      event.build_disease_event(disease_event.attributes)
      event.save!
      event.disease.disease.avr_groups << AvrGroup.std
      with_cdc_records(event) do |records|
        records[0].size.should_not == 0
      end
    end

    it "should not fail when treatment dates are nil" do
      with_cdc_records do |records|
        record = records[0].first
        record.treatment_dates = nil
        record.to_cdc.length.should == 191
        record.exp_treatment_date.first.should == "99999999"
      end
    end

    it "should not fail when lab collection dates are nil" do
      with_cdc_records do |records|
        record = records[0].first
        record.lab_collection_dates = nil
        record.to_cdc.length.should == 191
        record.exp_specsite_date.first.should == "        "
      end
    end

    it "should not fail when lab test dates are nil" do
      with_cdc_records do |records|
        record = records[0].first
        record.lab_test_dates = nil
        record.disease_name = "Syphilis"

        record.to_cdc.length.should == 191
        record.exp_specsite.first.should == "  "
        record.exp_syphtest.first.should == " "
      end
    end

    it "should correctly display treatment fields" do
      with_cdc_records do |records|
        records[0].first.to_cdc.length.should == 191
        records[0].first.to_cdc[129..136].should == 5.days.ago.to_date.strftime('%Y%m%d')
      end
    end

    it "should correctly initial exam date" do
      e = create_cdc_event
      e.disease_event.date_diagnosed = Date.today
      e.save!

      with_cdc_records(e) do |records|
        records[0].first.to_cdc.length.should == 191
        records[0].first.to_cdc[113..120].should == Date.today.strftime('%Y%m%d')
      end
    end

    it "should correctly display specsite fields" do
      with_cdc_records do |records|
        records[0].first.to_cdc.length.should == 191
        #exp_specsite
        records[0].first.to_cdc[84..85].should == Export::Cdc::HumanEvent.netss_specimen["Blood/Serum"]
        #exp_specsite_date
        records[0].first.to_cdc[86..91].should == 14.days.ago.to_date.strftime('%y%m%d')
      end
    end

    it "should correctly display specsite field when specimen in blank" do
      with_cdc_records do |records|
        record = records[0].first
        record.specimen_values = "{NULL}"
        record.to_cdc.length.should == 191
        record.exp_specsite.first.should == "  "
      end
    end

    it "should correctly display the closest date" do
       with_cdc_records do |records|
         d = 10.days.ago.to_date.to_s(:db)
         o = 16.days.ago.to_date.to_s(:db)
         n = 5.days.ago.to_date.to_s(:db)
         records[0].first.pg_closest_date(d, [n, o]).first.should == 5.days.ago.to_date
       end
    end

    it "should correctly display same or after date" do
       with_cdc_records do |records|
         d = 10.days.ago.to_date.to_s(:db)
         o = 16.days.ago.to_date.to_s(:db)
         n = 5.days.ago.to_date.to_s(:db)
         records[0].first.pg_same_or_after(d, [n, o]).first.should == 5.days.ago.to_date

         d = 10.days.ago.to_date.to_s(:db)
         o = 10.days.ago.to_date.to_s(:db)
         n = 5.days.ago.to_date.to_s(:db)
         records[0].first.pg_same_or_after(d, [n, o]).first.should == 10.days.ago.to_date

         d = 10.days.ago.to_date.to_s(:db)
         o = 11.days.ago.to_date.to_s(:db)
         n = 16.days.ago.to_date.to_s(:db)
         records[0].first.pg_same_or_after(d, [n, o]).first.should == nil
       end
    end

    it "should display '49' (state id) for the state field" do
      with_cdc_records do |records|
        records[0].first.to_cdc[2..3].should == "20"
      end
    end

    it "should display the last 2 digits of the mmwr year" do
      with_cdc_records do |records|
        expected_date = Mmwr.new.mmwr_year.to_s[2..3]
        records[0].first.to_cdc.length.should == 191
        records[0].first.to_cdc[4..5].should == expected_date
      end
    end

    it "should display the last 6 digits of the case record number" do
      with_cdc_records do |records|
        records[0].first.to_cdc.length.should == 191
        records[0][0].to_cdc[6..11].should == records[0][1].record_number[-6, 6]
      end
    end

    it "should display the 3 digit site code" do
      with_cdc_records do |records|
        records[0].first.to_cdc.length.should == 191
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
        records[0].first.to_cdc[17..21].should == '10311'
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

    it "should display race as 9" do
      with_cdc_records do |records|
        records[0].first.to_cdc[43...44].should == '9'
      end
    end

    it "should display ethnicity as 9" do
      with_cdc_records do |records|
        records[0][0].to_cdc[44...45].should == '9'
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
        records[0][0].to_cdc[54...55].should == '9'
      end
    end

    it "should display syphtest as a one digit code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[182...183].should == '1'
      end
    end

    it "should display syphtiter as a six digit code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[183...189].should == '64    '
      end
    end

    it "should display city as 9999" do
      with_cdc_records do |records|
        records[0][0].to_cdc[69...73].should == '9999'
      end
    end

    it "should display pid as 9" do
      with_cdc_records do |records|
        records[0][0].to_cdc[73...74].should == '9'
      end
    end

    it "should display origin as 9" do
      with_cdc_records do |records|
        records[0][0].to_cdc[75...76].should == '9'
      end
    end

    it "should display dx date as 99999999" do
      with_cdc_records do |records|
        records[0][0].to_cdc[76...84].should == '99999999'
      end
    end

    it "should display interview as 9" do
      with_cdc_records do |records|
        records[0][0].to_cdc[95...96].should == '9'
      end
    end

    it "should display partner as 9" do
      with_cdc_records do |records|
        records[0][0].to_cdc[96...97].should == '9'
      end
    end

    it "should display amind race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_indian)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[97...98].should == 'Y'
      end
    end

    it "should display asian race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_asian)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[98...99].should == 'Y'
      end
    end

    it "should display black race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_black)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[99...100].should == 'Y'
      end
    end

    it "should display nahaw race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_hawaiian)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[100...101].should == 'Y'
      end
    end

    it "should display white race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_white)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[101...102].should == 'Y'
      end
    end

    it "should display other race code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[102...103].should == 'Y'
      end
    end

    it "should display unknown race code" do
      e = create_cdc_event
      e.interested_party.person_entity.races << external_codes(:race_unknown)
      e.interested_party.person_entity.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[104...105].should == 'Y'
      end
    end

    it "should display raceref code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[103...104].should == 'Y'
      end
    end

    it "should display non-hispanic ethnicity code" do
      e = create_cdc_event
      e.interested_party.person_entity.person.ethnicity = external_codes(:ethnicity_non_hispanic)
      e.interested_party.person_entity.person.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[105...106].should == 'N'
      end
    end

    it "should display hispanic ethnicity code" do
      e = create_cdc_event
      e.interested_party.person_entity.person.ethnicity = external_codes(:ethnicity_hispanic)
      e.interested_party.person_entity.person.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[105...106].should == 'Y'
      end
    end

    it "should display unknown ethnicity code" do
      e = create_cdc_event
      e.interested_party.person_entity.person.ethnicity = external_codes(:ethnicity_unknown)
      e.interested_party.person_entity.person.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[105...106].should == 'U'
      end
    end

    it "should display other ethnicity code" do
      e = create_cdc_event
      e.interested_party.person_entity.person.ethnicity = external_codes(:ethnicity_other)
      e.interested_party.person_entity.person.save!
      with_cdc_records(e) do |records|
        records[0][0].to_cdc[105...106].should == 'N'
      end
    end

    it "should display no ethnicity code" do
      with_cdc_records do |records|
        records[0][0].to_cdc[105...106].should == 'R'
      end
    end

    it "should display netss code" do
      with_cdc_records do |records|
        records[0].first.to_cdc.length.should == 191

        records[0][0].to_cdc[-2, 2].should == '03'
      end
    end
  end
end