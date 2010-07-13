# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

require File.expand_path(File.dirname(__FILE__) +  '/../../../../../spec/spec_helper')

describe Export::Csv do
  include CsvSpecHelper
  include DiseaseSpecHelper
  include CoreFieldSpecHelper
  include PerinatalHepBSpecHelper

  before :all do
    disease_name = 'Hepatitis B Pregnancy Event'

    given_a_disease_named(disease_name)
    given_core_fields_loaded
    given_csv_fields_loaded
    
    given_p_hep_b_core_fields_loaded
    given_p_hep_b_csv_fields_loaded

    CoreFieldsDisease.create_perinatal_hep_b_associations
    CsvField.create_perinatal_hep_b_associations

    @disease = Disease.find_by_disease_name(disease_name)
  end

  after(:all) do
    CoreFieldsDisease.destroy_all
    CsvField.destroy_all
  end

  before(:each) do
    @event = human_event_with_demographic_info!(
      :event_with_disease_event,
      :last_name => "Johnson"
    )

    @event.disease_event.disease = @disease
    @event.save!

    @second_event = human_event_with_demographic_info!(
      :event_with_disease_event,
      :last_name => "Johnson"
    )
  end

  it "should still render CSV export properly for events without any P-Hep-B data" do
    output = to_arry(Export::Csv.export(@event, :show_disease_specific_fields => true))
    output.size.should == 2
    assert_values_in_result(output, 1, :patient_last_name => /#{@event.interested_party.person_entity.person.last_name}/)
    assert_values_in_result(output, 1, :expected_delivery_facility_name => //)
  end

  it "should not render P-Hep-B data if the event's disease is not mapped to P-Hep-B fields" do
    @event.disease_event.disease = Factory.create(:disease)
    @event.save!
    output = to_arry(Export::Csv.export(@event))
    output.size.should == 2
    assert_values_in_result(output, 1, :patient_last_name => /#{@event.interested_party.person_entity.person.last_name}/)
    output[0].include?("expected_delivery_facility_name").should be_false
  end

  it "should not render P-Hep-B data if the :show_disease_specific_fields is not present and there is more than one event to export" do
    output = to_arry(Export::Csv.export([@event, @second_event]))
    output.size.should == 3
    assert_values_in_result(output, 1, :patient_last_name => /#{@event.interested_party.person_entity.person.last_name}/)
    output[0].include?("expected_delivery_facility_name").should be_false
  end

  it "should not render P-Hep-B data if the :show_disease_specific_fields is false and there is more than one event to export" do
    output = to_arry(Export::Csv.export([@event, @second_event], :show_disease_specific_fields => false))
    output.size.should == 3
    assert_values_in_result(output, 1, :patient_last_name => /#{@event.interested_party.person_entity.person.last_name}/)
    output[0].include?("expected_delivery_facility_name").should be_false
  end

  describe "events with an expected delivery facility" do

    before(:each) do
      @expected_delivery_facility = add_expected_delivery_facility_to_event(@event, "Allen Hospital")
      @risk_factors = @event.interested_party.build_risk_factor(:pregnancy_due_date => (Date.today + 15.days))
      @risk_factors.save!

      @telephone_number = Factory.create(:telephone,
        :area_code => "555",
        :phone_number => "555-3333",
        :extension => "200",
        :entity => @event.expected_delivery_facility.secondary_entity
      )
    end

    it "should include expected delivery facility information in CSV export" do
      output = to_arry(Export::Csv.export(@event))
      assert_values_in_result(output, 1, :expected_delivery_facility_name => /Allen Hospital/)
      assert_values_in_result(output, 1, :expected_delivery_facility_area_code => /555/)
      assert_values_in_result(output, 1, :expected_delivery_facility_phone_number => /5553333/)
      assert_values_in_result(output, 1, :expected_delivery_facility_extension => /200/)
      assert_values_in_result(output, 1, :patient_pregnancy_due_date => /#{@risk_factors.pregnancy_due_date}/)
    end

  end

  describe "events with an actual delivery facility" do

    before(:each) do
      @actual_delivery_facility = add_actual_delivery_facility_to_event(@event,
        "Actual Hospital",
        :actual_delivery_date => Date.today - 15
      )

      @telephone_number = Factory.create(:telephone,
        :area_code => "555",
        :phone_number => "555-3333",
        :extension => "200",
        :entity => @event.actual_delivery_facility.secondary_entity
      )
    end

    it "should include actual delivery facility information in CSV export" do
      output = to_arry(Export::Csv.export(@event))
      assert_values_in_result(output, 1, :actual_delivery_facility_name => /Actual Hospital/)
      assert_values_in_result(output, 1, :actual_delivery_facility_area_code => /555/)
      assert_values_in_result(output, 1, :actual_delivery_facility_phone_number => /5553333/)
      assert_values_in_result(output, 1, :actual_delivery_facility_extension => /200/)
      assert_values_in_result(output, 1, :actual_delivery_facility_actual_delivery_date => /#{@actual_delivery_facility.actual_delivery_facilities_participation.actual_delivery_date}/)
    end
    
    it "should include actual delivery facility information in CSV export even when there is no actual_delivery_facilities_participation" do
      @actual_delivery_facility.actual_delivery_facilities_participation.destroy
      output = to_arry(Export::Csv.export(@event))
      assert_values_in_result(output, 1, :actual_delivery_facility_name => /Actual Hospital/)
      assert_values_in_result(output, 1, :actual_delivery_facility_area_code => /555/)
      assert_values_in_result(output, 1, :actual_delivery_facility_phone_number => /5553333/)
      assert_values_in_result(output, 1, :actual_delivery_facility_extension => /200/)
      assert_values_in_result(output, 1, :actual_delivery_facility_actual_delivery_date => //)
    end
  end

  
end

