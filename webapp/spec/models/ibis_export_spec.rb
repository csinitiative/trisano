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

describe IbisExport do

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


  context "IBIS exports" do
    let(:event) do
      Factory.create(:morbidity_event_with_disease, {
        :first_reported_PH_date => Date.parse("2009-11-29"),
        :created_at => DateTime.parse("2009-11-30 13:30")
      })
    end

    describe "includes records" do
      it "created on the first day of the date range" do
        IbisExport.exportable_ibis_records("2009-11-30", "2009-12-1").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-30", "2009-12-1")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created on the last day of the date range" do
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30")
        results.map(&:record_number).should == [event.record_number]
      end

      it "created between the start and end dates" do
        IbisExport.exportable_ibis_records("2009-11-15", "2009-12-15").should be_empty
        event.reload
        results = IbisExport.exportable_ibis_records("2009-11-15", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the first day of the date range" do
        IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated on the last day of the date range" do
        IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15")
        results.map(&:record_number).should == [event.record_number]
      end

      it "ibis updated between the start and end dates" do
        IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31").should be_empty
        event.update_attributes!(:ibis_updated_at => '2009-12-15')
        event.reload
        results = IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31")
        results.map(&:record_number).should == [event.record_number]
      end

      describe "sent to ibis, and then later deleted" do
        it "if deleted on the first day of the date range" do
          IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16").should == []
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          event.reload
          results = IbisExport.exportable_ibis_records("2009-12-15", "2009-12-16")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted on the last day of the date range" do
          IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15").should == []
          event.reload
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = IbisExport.exportable_ibis_records("2009-12-14", "2009-12-15")
          results.map(&:record_number).should == [event.record_number]
        end

        it "if deleted between the date ranges" do
          IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31").should == []
          event.reload
          event.update_attributes!(:sent_to_ibis => true, :deleted_at => "2009-12-15 15:00")
          results = IbisExport.exportable_ibis_records("2009-12-01", "2009-12-31")
          results.map(&:record_number).should == [event.record_number]
        end
      end
    end

    describe "excludes records" do
      it "if they don't have a disease" do
        event.disease_event.update_attributes!(:disease => nil)
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end

      it "if they are deleted" do
        event.update_attributes!(:deleted_at => DateTime.parse("2009-11-30 15:00"))
        IbisExport.exportable_ibis_records("2009-11-29", "2009-11-30").should == []
      end
    end
  end

end