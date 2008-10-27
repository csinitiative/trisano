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
require RAILS_ROOT + '/app/helpers/application_helper'

describe EventsHelper do

  include ApplicationHelper

  def simple_reference 
    @reference ||= OpenStruct.new(
      :code_description => "a code",
      :best_name => "A Name",
      :disease_name => "A Disease",
      :name => "Another Name"
    )
  end

  def mock_mixed_events
    p = mock_simple_event(:morbidity)
    c = mock_simple_event(:contact)
    [p, c]
  end

  def mock_complex_event
    @lab_result = mock_model(LabResult)
    @lab_result.stub!(:test_type).and_return("Biopsy")
    @lab_result.stub!(:lab_result_text).and_return("Positive")
    @lab_result.stub!(:interpretation).and_return("Sick")
    @lab_result.stub!(:specimen_source).and_return(simple_reference)
    @lab_result.stub!(:collection_date).and_return("2008-02-01")
    @lab_result.stub!(:lab_test_date).and_return("2008-02-02")
    @lab_result.stub!(:specimen_sent_to_uphl_yn).and_return(simple_reference)

    @lab_place = mock_model(Place)
    @lab_place.stub!(:name).and_return("A Lab")

    entity = mock_model(Entity)
    entity.stub!(:place_temp).and_return(@lab_place)

    lab_part = mock_model(Participation)
    lab_part.stub!(:secondary_entity).and_return(entity)
    lab_part.stub!(:lab_results).and_return([@lab_result])

    p = mock_simple_event(:morbidity)
    p.stub!(:labs).and_return([lab_part])

    p
  end

  def mock_simple_event(event_type)
    ExternalCode.stub!(:count).and_return(7)

    @person = mock_model(Person)
    @person.stub!(:last_name).and_return("Lastname")
    @person.stub!(:first_name).and_return("Firstname")
    @person.stub!(:middle_name).and_return("Middlename")
    @person.stub!(:birth_date).and_return("2008-01-01")
    @person.stub!(:date_of_death).and_return("2008-01-02")
    @person.stub!(:approximate_age_no_birthday).and_return(55)
    @person.stub!(:birth_gender).and_return(simple_reference)
    @person.stub!(:ethnicity).and_return(simple_reference)
    @person.stub!(:primary_language).and_return(simple_reference)
    @person.stub!(:disposition).and_return(simple_reference)

    entity = mock_model(Entity)
    entity.stub!(:address_entities_locations).and_return([])
    entity.stub!(:telephone_entities_locations).and_return([])
    entity.stub!(:person).and_return(@person)
    entity.stub!(:races).and_return([])

    patient = mock_model(Participation)
    patient.stub!(:primary_entity).and_return(entity)
    patient.stub!(:participations_treatments).and_return([])
    patient.stub!(:participations_risk_factor).and_return(nil)

    @disease = mock_model(DiseaseEvent)
    @disease.stub!(:disease).and_return(simple_reference)
    @disease.stub!(:disease_onset_date).and_return("2008-01-03")
    @disease.stub!(:date_diagnosed).and_return("2008-01-04")
    @disease.stub!(:hospitalized).and_return(simple_reference)
    @disease.stub!(:died).and_return(simple_reference)

    if event_type == :morbidity
      m = mock_model(MorbidityEvent)
      m.stub!(:type).and_return('MorbidityEvent')
    else
      m = mock_model(ContactEvent)
      m.stub!(:type).and_return('ContactEvent')
    end
    m.stub!(:id).and_return(1)
    m.stub!(:record_number).and_return("20080001")
    m.stub!(:event_onset_date).and_return("2008-01-05")
    m.stub!(:read_attribute).with("MMWR_week").and_return(1)
    m.stub!(:read_attribute).with("MMWR_year").and_return(2008)
    m.stub!(:age_info).and_return("30 years")

    m.stub!(:age_type).and_return(simple_reference)
    m.stub!(:imported_from).and_return(simple_reference)
    m.stub!(:lhd_case_status).and_return(simple_reference)
    m.stub!(:udoh_case_status).and_return(simple_reference)
    m.stub!(:outbreak_associated).and_return(simple_reference)
    m.stub!(:outbreak_name).and_return("an outbreak")

    m.stub!(:disease).and_return(@disease)
    m.stub!(:event_name).and_return("an event")
    m.stub!(:event_status).and_return("NEW")
    m.stub!(:investigation_started_date).and_return("2008-01-06")
    m.stub!(:investigation_completed_lhd_date).and_return("2008-01-07")
    m.stub!(:review_completed_UDOH_date).and_return("2008-01-08")
    m.stub!(:results_reported_to_clinician_date).and_return("2008-01-09")
    m.stub!(:first_reported_PH_date).and_return("2008-01-10")
    m.stub!(:investigation_completed_LHD_date).and_return("2008-01-11")
    m.stub!(:created_at).and_return("2008-01-12")
    m.stub!(:updated_at).and_return("2008-01-13")

    m.stub!(:investigator).and_return(simple_reference)
    m.stub!(:sent_to_cdc).and_return(true)

    m.stub!(:primary_jurisdiction).and_return(simple_reference)
    m.stub!(:patient).and_return(patient)

    m.stub!(:place_exposures).and_return([])
    m.stub!(:reporting_agency).and_return(nil)
    m.stub!(:reporter).and_return(nil)
    m.stub!(:labs).and_return([])
    m.stub!(:hospitalized_health_facilities).and_return([])
    m.stub!(:diagnosing_health_facilities).and_return([])
    m.stub!(:clinicians).and_return([])
    m.stub!(:contacts).and_return([])
    m.stub!(:answers).and_return([])

    m
  end

  def complex_event_output
    out = simple_event_output(:morbidity) 

    out << "\"\",Lab Results\n\"\","

    out << lab_header.join(",") + "\n" 
    out << '"",'
    out << "#{@lab_place.name},"
    out << "#{@lab_result.test_type},"
    out << "#{@lab_result.lab_result_text},"
    out << "#{@lab_result.interpretation},"
    out << "#{@lab_result.specimen_source.code_description},"
    out << "#{@lab_result.collection_date},"
    out << "#{@lab_result.lab_test_date},"
    out << "#{@lab_result.specimen_sent_to_uphl_yn.code_description}"
    out << "\n"
  end

  def mixed_event_output
    simple_event_output(:morbidity) + simple_event_output(:contact)
  end

  def simple_event_output(event_type)
    m = mock_simple_event(event_type)
    out = event_header(event_type).join(",") + "\n"
    out << "#{m.id},"
    out << "#{m.record_number},"
    out << "#{@person.last_name},"
    out << "#{@person.first_name},"
    out << "#{@person.middle_name},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'

    out << "#{@person.birth_date},"
    out << "#{@person.approximate_age_no_birthday},"
    out << "#{m.age_info},"
    out << '"",'
    out << '"",'
    out << '"",'

    out << "#{@person.birth_gender.code_description},"
    out << "#{@person.ethnicity.code_description},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{@person.primary_language.code_description},"
    if event_type == :contact
      out << "#{@person.disposition.code_description},"
    end
    out << "#{@disease.disease.disease_name},"
    out << "#{@disease.disease_onset_date},"
    out << "#{@disease.date_diagnosed},"
    out << '"",'
    out << "#{@disease.hospitalized.code_description},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{@disease.died.code_description},"
    out << "#{@person.date_of_death},"
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << '"",'
    out << "#{m.imported_from.code_description},"
    if event_type == :morbidity
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << '"",'
      out << "#{m.results_reported_to_clinician_date},"
      out << "#{m.first_reported_PH_date},"
      out << "#{m.event_onset_date},"
      out << "#{m.read_attribute("MMWR_week")},"
      out << "#{m.read_attribute("MMWR_year")},"
      out << "#{m.lhd_case_status.code_description},"
      out << "#{m.udoh_case_status.code_description},"
      out << "#{m.outbreak_associated.code_description},"
      out << "#{m.outbreak_name},"
      out << "#{m.event_name},"
      out << "#{m.primary_jurisdiction.name},"
      out << '"",'
      out << "#{m.event_status},"
      out << "#{m.investigation_started_date},"
      out << "#{m.investigation_completed_LHD_date},"
      out << "#{m.review_completed_UDOH_date},"
      out << "#{m.investigator.best_name},"
      out << "#{m.sent_to_cdc},"
    end
    out << "#{m.created_at},"
    out << "#{m.updated_at}"
    out << "\n"
  end

  def lab_header
    %w(lab_name
    test_type
    lab_result
    interpretation
    specimen_source
    collection_date
    lab_test_date
    specimen_sent_to_uphl)
  end

  def event_header(event_type)
    header_array = []
    p_or_c = event_type == :morbidity ? "patient" : "contact"

    header_array << "internal_id"
    header_array << "record_number"
    
    header_array << "#{p_or_c}_last_name"
    header_array << "#{p_or_c}_first_name"
    header_array << "#{p_or_c}_middle_name"
    header_array << "#{p_or_c}_address_street_number"
    header_array << "#{p_or_c}_address_street_name"
    header_array << "#{p_or_c}_address_unit_number"
    header_array << "#{p_or_c}_address_city"
    header_array << "#{p_or_c}_address_state"
    header_array << "#{p_or_c}_address_county"
    header_array << "#{p_or_c}_address_postal_code"
    header_array << "#{p_or_c}_birth_date"
    header_array << "#{p_or_c}_approximate_age_no_birthdate"
    header_array << "#{p_or_c}_age_at_onset"
    header_array << "#{p_or_c}_phone_area_code"
    header_array << "#{p_or_c}_phone_phone_number"
    header_array << "#{p_or_c}_phone_extension"
    header_array << "#{p_or_c}_birth_gender"
    header_array << "#{p_or_c}_ethnicity"
    header_array << "race_1"
    header_array << "race_2"
    header_array << "race_3"
    header_array << "race_4"
    header_array << "race_5"
    header_array << "race_6"
    header_array << "race_7"
    header_array << "#{p_or_c}_language"

    if event_type == :contact
      header_array << "contact_disposition"
    end

    header_array << "#{p_or_c}_disease"
    header_array << "#{p_or_c}_disease_onset_date"
    header_array << "#{p_or_c}_date_diagnosed"
    header_array << "#{p_or_c}_diagnosing_health_facility"
    header_array << "#{p_or_c}_hospitalized"
    header_array << "#{p_or_c}_hospitalized_health_facility"
    header_array << "#{p_or_c}_hospital_admission_date"
    header_array << "#{p_or_c}_hospital_discharge_date"
    header_array << "#{p_or_c}_hospital_medical_record_no"
    header_array << "#{p_or_c}_died"
    header_array << "#{p_or_c}_date_of_death"
    header_array << "#{p_or_c}_pregnant"
    header_array << "#{p_or_c}_clinician_last_name"
    header_array << "#{p_or_c}_clinician_first_name"
    header_array << "#{p_or_c}_clinician_middle_name"
    header_array << "#{p_or_c}_clinician_phone_area_code"
    header_array << "#{p_or_c}_clinician_phone_phone_number"
    header_array << "#{p_or_c}_clinician_phone_extension"
    header_array << "#{p_or_c}_food_handler"
    header_array << "#{p_or_c}_healthcare_worker"
    header_array << "#{p_or_c}_group_living"
    header_array << "#{p_or_c}_day_care_association"
    header_array << "#{p_or_c}_occupation"
    header_array << "#{p_or_c}_risk_factors"
    header_array << "#{p_or_c}_risk_factors_notes"
    header_array << "#{p_or_c}_imported_from"

    if event_type == :morbidity
      header_array << "reporting_agency"
      header_array << "reporter_last_name"
      header_array << "reporter_first_name"
      header_array << "reporter_phone_area_code"
      header_array << "reporter_phone_phone_number"
      header_array << "reporter_phone_extension"
      header_array << "results_reported_to_clinician_date"
      header_array << "first_reported_PH_date"
      header_array << "event_onset_date"
      header_array << "MMWR_week"
      header_array << "MMWR_year"
      header_array << "lhd_case_status"
      header_array << "udoh_case_status"
      header_array << "outbreak_associated"
      header_array << "outbreak_name"
      header_array << "event_name"
      header_array << "jurisdiction_of_investigation"
      header_array << "jurisdiction_of_residence"
      header_array << "event_status"
      header_array << "investigation_started_date"
      header_array << "investigation_completed_lhd_date"
      header_array << "review_completed_UDOH_date"
      header_array << "investigator"
      header_array << "sent_to_cdc"
    end
    header_array << "event_created_date"
    header_array << "event_last_updated_date"
  end

  describe "rendering csv output" do
    it "should render csv output for 1 morbidity event" do
      render_events_csv(mock_simple_event(:morbidity)).should == simple_event_output(:morbidity)
    end

   it "should render csv output for 1 contact event" do
     render_events_csv(mock_simple_event(:contact)).should == simple_event_output(:contact)
   end

   it "should render csv output for multiple mixed events" do
     render_events_csv(mock_mixed_events).should == mixed_event_output
   end

   it "should render treatments and labs" do
     render_events_csv(mock_complex_event).should == complex_event_output
     #TODO: Really test treatments
   end

   #TODO
   it "should render child contacts and places" do
   end

  end

  describe "the state_controls method" do

    describe "when the event state is 'asssigned to LHD'" do
      before(:each) do
        mock_user
        mock_event
        @event_1.stub!(:event_status).and_return("ASGD-LHD")
        @jurisdiction = mock_model(Place)
        @jurisdiction.stub!(:entity_id).and_return(1)
        User.stub!(:current_user).and_return(@user)
      end

      describe "and the user is allowed to accept an event" do
        before(:each) do
          @user.stub!(:is_entitled_to_in?).and_return(true)
        end
       
        it "should return a properly constructed form that posts to the morbidity event's controller's state action" do
          pending "There are serious difficulties testing Haml helpers in RSpec.  Pending till figured out."
          form = state_controls(@event_1, @jurisdiction)
          # form test here
            # radio button test here
        end
          
      end

      describe "when the user is not allowed to accept an event" do
      end
    end
   
    # Repeat the above pattern as new state transitions are implemented
  end
    
  end
