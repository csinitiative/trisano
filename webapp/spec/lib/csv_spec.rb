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

describe Export::Csv do

  before :all do
    file = File.join(File.dirname(__FILE__), '../../../plugins/trisano_en/config/misc/en_csv_fields.yml')
    CsvField.load_csv_fields(YAML.load_file(file))
    @events = [
      Factory(:morbidity_event, :first_reported_PH_date => Date.yesterday),
      Factory(:morbidity_event, :first_reported_PH_date => Date.yesterday),
      Factory(:morbidity_event, :first_reported_PH_date => Date.yesterday, :deleted_at => DateTime.parse('2008-01-01T12:00:00'))
    ]
  end

  after(:all) { CsvField.destroy_all }

  before(:each) do
    # There are 7 races
    ExternalCode.stubs(:count).returns(7)
  end
  
  it "should expose an export method that takes an event or a list of events and an optional proc" do
    lambda { Export::Csv.export(@events.first) }.should_not raise_error()
    lambda { Export::Csv.export(@events[0,1])  }.should_not raise_error()
    lambda { Export::Csv.export(@events[0,1]) { @events.first }}.should_not raise_error()
  
    lambda { Export::Csv.export( Object.new) }.should raise_error(ArgumentError)
  end
  
  describe "when passed a single simple event" do
    it "should output event, contact, place, treatment, and lab result HEADERS on one line" do
      to_arry(Export::Csv.export(@events.first, :export_options => %w(labs treatments places contacts hospitalization_facilities))).first.should == event_header(:morbidity) + "," + lab_header + "," + treatment_header + "," + event_header(:place) + "," + event_header(:contact)
    end
  
    it "should output content for a simple event" do
      event = @events.first
      a = to_arry( Export::Csv.export(event) )
      a.size.should == 2
      a[1].include?(event.interested_party.person_entity.person.last_name).should be_true
    end
  end
  
  describe "when passed multiple simple events" do
    it "should iterate over each event" do
      a = to_arry( Export::Csv.export(@events) )
      a.size.should == 3
      a[1].include?(@events.first.interested_party.person_entity.person.last_name).should be_true
      a[2].include?(@events.second.interested_party.person_entity.person.last_name).should be_true
    end
  end
  
  # Debt: Does not yet test places or assessment events
  describe "when passed a complex (fully loaded) assessment event" do
    it "should output the right information"

    # Unable to to the assessment event CSV export.  It seems we get two extra
    # blank fields just before the lab name, but am missing two blank fields
    # just before the birthday field.

    #it "should output the right information" do
    #  e = csv_mock_event(:assessment)
    #  a = to_arry( Export::Csv.export( e, {:export_options => ["labs", "treatments", "hospitalization_facilities"], :disease => csv_mock_disease } ) )
    #  a[0].include?("disease_specific_assessment_q").should be_true
    #  a[1].should == "#{event_output(:assessment, e, {:disease => csv_mock_disease}) + "," + lab_output + "," + treatment_output}"
    #end
  end

  describe "when passed a complex (fully loaded) morbidity event" do
    it "should output the right information" do
      e = csv_mock_event(:morbidity)
      a = to_arry( Export::Csv.export( e, {:export_options => ["labs", "treatments", "hospitalization_facilities"], :disease => csv_mock_disease } ) )
      a[0].include?("disease_specific_morb_q").should be_true
      a[1].should == "#{event_output(:morbidity, e, {:disease => csv_mock_disease}) + "," + lab_output + "," + treatment_output}"
    end
  end
    
  describe "when passed an event w/ a contact" do
    before do
      @morbidity_event = @events.first
      @contact_event   = Factory.create(:contact_with_disease)
      @contact_event.parent_event = @morbidity_event
      @contact_event.save!
    end
  
    it "should output the contact" do
      result = to_arry(Export::Csv.export(@morbidity_event, :export_options => %w(contacts)))
      assert_values_in_result(result, 1, :contact_disease => /The dreaded lurgy (\d+)/i)
    end
  
    describe "and when contact promoted to cmr" do
      before do
        login_as_super_user
        @contact_event.promote_to_morbidity_event.should be_true
      end
  
      it "should still output contact" do
        result = to_arry(Export::Csv.export(@morbidity_event, :export_options => %w(contacts)))
        assert_values_in_result(result, 1, :contact_disease => /The dreaded lurgy (\d+)/i)
      end
    end
  end
  
  
  describe 'picking codes over descriptions' do
    before(:each) do
      @county = Factory.build(:external_code)
      @county.stubs(:jurisdiction).returns(nil)
      @address = Factory.build(:address)
      @address.attributes = {
        :street_number => nil,
        :street_name => nil,
        :unit_number => nil,
        :city => nil,
        :state => nil,
        :county => @county,
        :postal_code => nil
      }
      @event = @events.first
    end
  
    it 'should return county code, not name' do
      @event.stubs(:address).returns(@address)
      @county.expects(:the_code).returns('56')
      Export::Csv.export(@event, {'patient_address_county' => 'use_code'}).should =~ /56/i
    end
  
    it 'should pick cdc code, rather then disease name' do
      d = Factory.build(:disease)
      d.cdc_code = '11010'
      de = Factory.build(:disease_event, :disease => d)
      @event.stubs(:disease_event).returns(de)
      Export::Csv.export(@event, {'patient_disease' => 'use_code'}).should =~ /#{d.cdc_code}/i
    end
  end

  describe "varying numbers of varying 'multiples'" do

    describe "where there are multiple hospitalization facilities" do

      before(:each) do
        @event = human_event_with_demographic_info!(:morbidity_event,
          :last_name => "Johnson"
        )
        
        @hospital_one = add_hospitalization_facility_to_event(@event,
          "Allen Hospital",
          :admission_date => Date.today - 5,
          :discharge_date => Date.today - 1,
          :medical_record_number => "12345-1"
        )

        @hospital_two = add_hospitalization_facility_to_event(@event,
          "Peabody Hospital",
          :admission_date => Date.today - 10,
          :discharge_date => Date.today - 6,
          :medical_record_number => "12345-2"
        )
        
      end

      it "should render multiple hospitalization facilities" do
        output = to_arry(Export::Csv.export(@event, :export_options => %w(labs treatments places contacts hospitalization_facilities)))
        output.size.should == 3
        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :patient_hospital_admission_date => /#{@hospital_one.hospitals_participation.admission_date}/)
        assert_values_in_result(output, 1, :patient_hospital_discharge_date => /#{@hospital_one.hospitals_participation.discharge_date}/)
        assert_values_in_result(output, 1, :patient_hospital_medical_record_no => /#{@hospital_one.hospitals_participation.medical_record_number}/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :patient_hospital_admission_date => /#{@hospital_two.hospitals_participation.admission_date}/)
        assert_values_in_result(output, 2, :patient_hospital_discharge_date => /#{@hospital_two.hospitals_participation.discharge_date}/)
        assert_values_in_result(output, 2, :patient_hospital_medical_record_no => /#{@hospital_two.hospitals_participation.medical_record_number}/)
      end

      it "should not render blanks for non-hospital columns in the first row" do
        output = to_arry(Export::Csv.export(@event, :export_options => %w(labs treatments places contacts)))
        assert_values_in_result(output, 1, :patient_event_id => /#{@event.id}/)
        assert_values_in_result(output, 1, :patient_record_number => /#{@event.record_number}/)
        assert_values_in_result(output, 1, :patient_last_name => /Johnson/)
      end
      
      
      it "should render blanks for non-hospital columns in the second row, except for id" do
        output = to_arry(Export::Csv.export(@event, :export_options => %w(labs treatments places contacts hospitalization_facilities)))
        assert_values_in_result(output, 2, :patient_event_id => /#{@event.id}/)
        assert_values_in_result(output, 2, :patient_record_number => //)
        assert_values_in_result(output, 2, :patient_last_name => //)
      end

      it "should not render hospitals if that option is not passed to the export" do
        output = to_arry(Export::Csv.export(@event))
        output.size.should == 2
        output[0].include?("patient_hospitalization_facility").should be_false
      end
      
      it "should render properly when there are more hospitals than labs" do
        @hospital_three = add_hospitalization_facility_to_event(@event,
          "Casteen Hospital",
          :admission_date => Date.today - 15,
          :discharge_date => Date.today - 11,
          :medical_record_number => "12345-3"
        )

        @lab_one = add_lab_to_event(@event,
          "ARUP",
          :result_value => "green",
          :units => "clicks"
        )

        @lab_two = add_lab_to_event(@event,
          "ACME",
          :result_value => "yellow",
          :units => "drops"
        )

        output = to_arry(Export::Csv.export(@event, :export_options => %w(labs hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :lab_name => /ARUP/)
        assert_values_in_result(output, 1, :lab_result_value => /green/)
        assert_values_in_result(output, 1, :lab_units => /clicks/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :lab_name => /ACME/)
        assert_values_in_result(output, 2, :lab_result_value => /yellow/)
        assert_values_in_result(output, 2, :lab_units => /drops/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => /Casteen Hospital/)
        assert_values_in_result(output, 3, :lab_name => //)
        assert_values_in_result(output, 3, :lab_result_value => //)
        assert_values_in_result(output, 3, :lab_units => //)
      end
      
      it "should render properly when there are more labs than hospitals" do
        @lab_one = add_lab_to_event(@event,
          "ARUP",
          :result_value => "green",
          :units => "clicks"
        )

        @lab_two = add_lab_to_event(@event,
          "ACME",
          :result_value => "yellow",
          :units => "drops"
        )

        @lab_three = add_lab_to_event(@event,
          "LALA",
          :result_value => "peas",
          :units => "pods"
        )

        output = to_arry(Export::Csv.export(@event, :export_options => %w(labs hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :lab_name => /ARUP/)
        assert_values_in_result(output, 1, :lab_result_value => /green/)
        assert_values_in_result(output, 1, :lab_units => /clicks/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :lab_name => /ACME/)
        assert_values_in_result(output, 2, :lab_result_value => /yellow/)
        assert_values_in_result(output, 2, :lab_units => /drops/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => //)
        assert_values_in_result(output, 3, :lab_name => /LALA/)
        assert_values_in_result(output, 3, :lab_result_value => /peas/)
        assert_values_in_result(output, 3, :lab_units => /pods/)
      end

      it "should not render labs if that option is not passed to the export" do
        @lab_one = add_lab_to_event(@event,
          "ARUP",
          :result_value => "green",
          :units => "clicks"
        )
        
        output = to_arry(Export::Csv.export(@event))
        output.size.should == 2
        output[0].include?("lab_name").should be_false
      end
      
      it "should render properly when there are more hospitals than treatments" do
        @hospital_three = add_hospitalization_facility_to_event(@event,
          "Casteen Hospital",
          :admission_date => Date.today - 15,
          :discharge_date => Date.today - 11,
          :medical_record_number => "12345-3"
        )


        @treatment_one = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Foot massage"))
        @treatment_two = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Some pills"))

        output = to_arry(Export::Csv.export(@event, :export_options => %w(treatments hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :treatment_name => /Foot massage/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :treatment_name => /Some pills/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => /Casteen Hospital/)
        assert_values_in_result(output, 3, :treatment_name => //)
      end
      
      it "should render properly when there are more treatments than hospitals" do
        @treatment_one = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Foot massage"))
        @treatment_two = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Some pills"))
        @treatment_three = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Lots of love"))
        
        output = to_arry(Export::Csv.export(@event, :export_options => %w(treatments hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :treatment_name => /Foot massage/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :treatment_name => /Some pills/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => //)
        assert_values_in_result(output, 3, :treatment_name => /Lots of love/)
      end

      it "should not render treatments if that option is not passed to the export" do
        @treatment_one = add_treatment_to_event(@event, :treatment => Factory.create(:treatment, :treatment_name => "Foot massage"))
        output = to_arry(Export::Csv.export(@event))
        output.size.should == 2
        output[0].include?("treatment_name").should be_false
      end

      it "should render properly when there are more hospitals than contacts" do
        @hospital_three = add_hospitalization_facility_to_event(@event,
          "Casteen Hospital",
          :admission_date => Date.today - 15,
          :discharge_date => Date.today - 11,
          :medical_record_number => "12345-3"
        )

        @contact_one = add_contact_to_event(@event, "contact_one")
        @contact_two = add_contact_to_event(@event, "contact_two")

        output = to_arry(Export::Csv.export(@event, :export_options => %w(contacts hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :contact_last_name => /contact_one/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :contact_last_name => /contact_two/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => /Casteen Hospital/)
        assert_values_in_result(output, 3, :contact_last_name => //)
      end
      
      it "should render properly when there are more contacts than hospitals" do
        @contact_one = add_contact_to_event(@event, "contact_one")
        @contact_two = add_contact_to_event(@event, "contact_two")
        @contact_three = add_contact_to_event(@event, "contact_three")

        output = to_arry(Export::Csv.export(@event, :export_options => %w(contacts hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :contact_last_name => /contact_one/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :contact_last_name => /contact_two/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => //)
        assert_values_in_result(output, 3, :contact_last_name => /contact_three/)
      end

      it "should not render contacts if that option is not passed to the export" do
        @contact_one = add_contact_to_event(@event, "contact_one")
        output = to_arry(Export::Csv.export(@event))
        output.size.should == 2
        output[0].include?("contact_last_name").should be_false
      end
      
      it "should render properly when there are more hospitals than place exposures" do
        @hospital_three = add_hospitalization_facility_to_event(@event,
          "Casteen Hospital",
          :admission_date => Date.today - 15,
          :discharge_date => Date.today - 11,
          :medical_record_number => "12345-3"
        )

        @place_one = add_place_to_event(@event, "place_one")
        @place_two = add_place_to_event(@event, "place_two")

        output = to_arry(Export::Csv.export(@event, :export_options => %w(places hospitalization_facilities)))
        output.size.should == 4
        
        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :place_name => /place_one/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :place_name => /place_two/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => /Casteen Hospital/)
        assert_values_in_result(output, 3, :place_name => //)
      end
      
      it "should render properly when there are more place exposures than hospitals" do
        @place_one = add_place_to_event(@event, "place_one")
        @place_two = add_place_to_event(@event, "place_two")
        @place_three = add_place_to_event(@event, "place_three")

        output = to_arry(Export::Csv.export(@event, :export_options => %w(places hospitalization_facilities)))
        output.size.should == 4

        assert_values_in_result(output, 1, :patient_hospitalization_facility => /Allen Hospital/)
        assert_values_in_result(output, 1, :place_name => /place_one/)

        assert_values_in_result(output, 2, :patient_hospitalization_facility => /Peabody Hospital/)
        assert_values_in_result(output, 2, :place_name => /place_two/)

        assert_values_in_result(output, 3, :patient_hospitalization_facility => //)
        assert_values_in_result(output, 3, :place_name => /place_three/)
      end

      it "should not render places if that option is not passed to the export" do
        @place_one = add_place_to_event(@event, "place_one")
        output = to_arry(Export::Csv.export(@event))
        output.size.should == 2
        output[0].include?("place_name").should be_false
      end
      
      describe "and there are contacts on the main event and contacts themselves listed in the export" do

        it "should blank out demographic data on the second row of a contact event" do
          @contact = add_contact_to_event(@event, "contact_one")
          @contact_hospital = add_hospitalization_facility_to_event(@contact,
            "Contact Hospital",
            :admission_date => Date.today - 5,
            :discharge_date => Date.today - 1,
            :medical_record_number => "12345-1"
          )
          
          @contact_hospital_two = add_hospitalization_facility_to_event(@contact,
            "Contact Hospital Two",
            :admission_date => Date.today - 10,
            :discharge_date => Date.today - 6,
            :medical_record_number => "12345-2"
          )

          output = to_arry(Export::Csv.export([@event, @contact], :export_options => %w(contacts hospitalization_facilities)))
          output[4].include?(@contact.id.to_s).should be_true
          output[4].include?("contact_one").should be_true
          output[5].include?(@contact.id.to_s).should be_true
          output[5].include?("contact_one").should be_false
        end
      end
    end
  end
end

