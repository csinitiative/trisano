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
  include PerinatalHepBSpecHelper

  before :all do
    file = File.join(File.dirname(__FILE__), '../../../trisano_en/config/misc/en_csv_fields.yml')
    CsvField.load_csv_fields(YAML.load_file(file))

    file = File.join(File.dirname(__FILE__), '../../config/misc/en_csv_fields.yml')
    CsvField.load_csv_fields(YAML.load_file(file))
  end

  after(:all) { CsvField.destroy_all }

  before(:each) do
    @event = human_event_with_demographic_info!(
      :morbidity_event,
      :last_name => "Johnson"
    )
  end

  it "should still render CSV export properly for events without any P-Hep-B data" do
    output = to_arry(Export::Csv.export(@event, :export_options => %w(labs treatments places contacts)))
    output.size.should == 2
    assert_values_in_result(output, 1, :patient_last_name => /#{@event.interested_party.person_entity.person.last_name}/)
    assert_values_in_result(output, 1, :expected_delivery_facility_name => //)
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
      assert_values_in_result(output, 1, :expected_delivery_facility_expected_delivery_date => /#{@risk_factors.pregnancy_due_date}/)
    end

    it "should include expected delivery facility information in CSV export even when there is no expected_delivery_facilities_participation" do
      @expected_delivery_facility.expected_delivery_facilities_participation.destroy
      output = to_arry(Export::Csv.export(@event))
      assert_values_in_result(output, 1, :expected_delivery_facility_name => /Allen Hospital/)
      assert_values_in_result(output, 1, :expected_delivery_facility_area_code => /555/)
      assert_values_in_result(output, 1, :expected_delivery_facility_phone_number => /5553333/)
      assert_values_in_result(output, 1, :expected_delivery_facility_extension => /200/)
      assert_values_in_result(output, 1, :expected_delivery_facility_expected_delivery_date => //)
    end
  end

  describe "events with an actual delivery facility" do

    before(:each) do
      @actual_delivery_facility = add_actual_delivery_facility_to_event(@event,
        "Actual Hospital",
        :actual_delivery_date => Date.today + 15
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

