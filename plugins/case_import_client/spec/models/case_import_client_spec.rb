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
require 'spec_helper'

describe CaseImportClient do
  before do
    diseases(:aids).avr_groups = [AvrGroup.find_or_create_by_name("STD Data")]
    @first_reported_date = Date.yesterday.to_s(:db)
  end

  def create_cdc_event(config = {})
    event_hash = {
        "age_at_onset" => 26,
        "record_number" => "00001111",
        "state_case_status_id" => external_codes(:case_status_probable).id,
        "outbreak_associated_id" => external_codes(:unknown_outbreak).id,
        "first_reported_PH_date" => @first_reported_date,
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
            "secondary_entity_id" => entities(:Southeastern_District).id
        },
        "address_attributes" => {
            "county_id" => external_codes(:county_salt_lake).id,
            "city" => "Atlanta",
            "postal_code" => "10010"
        },
        "disease_event_attributes" => {
            "disease_id" => diseases(:aids).id,
            "disease_onset_date" => @first_reported_date
        },
        "answers" => {
          "0" =>
           { "question_id" => questions(:cdc_pattern_1).id,
            "export_conversion_value_id" => export_conversion_values(:drop_down_yes).id },
          "1" =>
           { "question_id" => questions(:cdc_pattern_2).id,
            "text_answer" => "Not sure" },
          "2" =>
           { "question_id" => questions(:ks_pattern_1).id,
            "export_conversion_value_id" => export_conversion_values(:drop_down_no).id },
          "3" =>
           { "question_id" => questions(:ks_pattern_2).id,
            "text_answer" => "I do not know" },
          "4" =>
           { "question_id" => questions(:other_st_pattern_1).id,
            "export_conversion_value_id" => export_conversion_values(:drop_down_unknown).id },
          "5" =>
           { "question_id" => questions(:other_st_pattern_2).id,
            "text_answer" => "Other" },
        }
    }.merge(config)

    event = MorbidityEvent.new(event_hash)
    event.save!
    event.update_attribute(:created_at, config[:created_at] || Date.yesterday.to_s(:db))
    event.reload
  end

  def with_cdc_records(events = [])
    events.map!(&:id)
    records = CaseImportClient.daily_export
    yield records, events if block_given?
  end

  describe 'running cdc export' do
    fixtures :events, :questions, :disease_events, :diseases, :cdc_disease_export_statuses, :export_columns, :export_conversion_values, :entities, :addresses, :people_races, :places, :places_types

    it 'should return daily records' do
      old = create_cdc_event(:created_at => Date.yesterday - 1.minute)
      today = create_cdc_event(:created_at => Date.today)
      with_cdc_records([old, create_cdc_event, create_cdc_event, create_cdc_event, today]) do |records, events|
        records.should_not be_nil
        records.select {|r| events.include?(r.id) }.length.should == 3
      end
    end

    it "should request web service" do
      5.times.each { create_cdc_event }
      CaseImportClient.start_import
    end

    it 'should return correct event fields' do
      with_cdc_records([create_cdc_event]) do |records, events|
        r = records.find {|r| events.include?(r.id) }
        r.races.should == [export_conversion_values(:race_white_export_value).value_to]
        r.outbreak_name.should == "9"
        r.disease_onset_date.should == Date.parse(@first_reported_date).strftime("%Y-%m-%dT00:00:00")
        r.first_reported_date.should == Date.parse(@first_reported_date).strftime("%Y-%m-%dT00:00:00")
        r.mmwr_year.should_not == nil
        r.mmwr_week.should_not == nil
        r.jurisdiction_name.should == places(:Southeastern_District).short_name
        r.investigation_status.should == "accepted_by_lhd"
        r.record_number.should == "00001111"
        r.disease_name.should == diseases(:aids).disease_name
        r.created_date.should_not == nil
        r.age_at_onset.should == (Date.today.year - Date.parse('01/01/1975').year)
        r.age_at_onset_type.should == external_codes(:age_type_years).the_code
        r.sex.should == export_conversion_values(:gender_female).value_to
        r.state_case_status_code.should == external_codes(:case_status_probable).the_code
        r.state_case_status_value.should == export_conversion_values(:case_status_probable_value).value_to
        r.zip.should == "10010"
        r.city.should == "Atlanta"
        r.county.should == export_conversion_values(:salt_lake_county_export_value).value_to
        r.ethnicity.should == export_conversion_values(:ethnicity_non_hispanic_value).value_to
      end
    end

    it 'should return enzym patterns' do
      with_cdc_records([create_cdc_event]) do |records, events|
        r = records.find {|r| events.include?(r.id) }
        r.ks_pattern_1.should == export_conversion_values(:drop_down_no).value_to
        r.cdc_pattern_1.should == export_conversion_values(:drop_down_yes).value_to
        r.othr_st_pattern_1.should == export_conversion_values(:drop_down_unknown).value_to
        r.othr_st_pattern_2.should match "Other"
        r.ks_pattern_2.should match "I do not know"
        r.cdc_pattern_2.should match "Not sure"
      end
    end
  end
end
