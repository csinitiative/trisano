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

  def mock_answers    
    answers = []
    answers << Answer.new(:text_answer => 'Numero uno')
    answers << Answer.new(:text_answer => 'No short name')
    answers << Answer.new(:text_answer => 'No (answer three)')    
    answers[0].stub!(:short_name).and_return('short_name_1')
    answers[2].stub!(:short_name).and_return('short_name_3')
    answers
  end

  def mock_lab_place
    mock = mock(Place)
    mock.should_receive(:name).at_least(1).and_return('Some Lab')
    mock
  end

  def mock_lab_entity
    mock = mock(Entity)
    mock.stub!(:current_place).and_return(mock_lab_place)
    mock
  end

  def mock_contact
    address = mock(Address)
    address.stub!(:city).and_return('Newton Falls')
    address.stub!(:county_name).and_return('Summit')
    address.stub!(:postal_code).and_return('55555')
    person = mock(Person)
    person.stub!(:age).and_return('11')
    person.stub!(:birth_gender_description).and_return('Male') 
    person.stub!(:ethnicity_description).and_return('Not latino')
    person.stub!(:race_description).and_return('White')
    person.stub!(:primary_language_description).and_return('English')
    person.stub!(:address).and_return(address)
    entity = mock(Entity)
    entity.stub!(:person).and_return(person)
    mock = mock(Participation)
    mock.stub!(:active_secondary_entity).and_return(entity)
    mock
  end

  def mock_clinician
    address = mock(Address)
    address.stub!(:number_and_street).and_return('777 Some Address')
    address.stub!(:unit_number).and_return('21')
    address.stub!(:city).and_return('Some City')
    address.stub!(:postal_code).and_return('77777')
    address.stub!(:county_name).and_return('Some County')
    address.stub!(:state_name).and_return('Utah')
    address.stub!(:district_name).and_return('Some District')
    phone = mock(Telephone)
    phone.stub!(:simple_format).and_return('(555)555-5555')
    person = mock(Person)    
    person.stub!(:full_name).and_return('Joe Clinic')
    person.stub!(:telephone).and_return(phone)
    person.stub!(:address).and_return(address)
    entity = mock(Entity)
    entity.stub!(:person).and_return(person)
    mock = mock(Participation)
    mock.stub!(:active_secondary_entity).and_return(entity)
    mock
  end

  def mock_event
    @event_1 = mock_model(Event)
    @lab = mock_model(Participation)
    @lab_result = mock_model(LabResult)

    @event_1.stub!(:labs).and_return([@lab])

    [].stub!(:empty?).and_return(false)
    @lab.stub!(:secondary_entity).and_return(mock_lab_entity)
    @lab.stub!(:lab_results).and_return([@lab_result])
    @lab.stub!(:each).and_yield(@lab_result)

    @event_status = mock_model(ExternalCode)
    @imported_from = mock_model(ExternalCode)
    @udoh_case_status =mock_model(ExternalCode)
    @lhd_case_status =mock_model(ExternalCode)
    @outbreak_associated = mock_model(Code)
    @hospitalized = mock_model(ExternalCode)
    @died = mock_model(ExternalCode)
    @pregnant = mock_model(ExternalCode)
    @specimen_source = mock_model(ExternalCode)
    @specimen_sent_to_uphl_yn = mock_model(ExternalCode)
    @pregant = mock_model(ExternalCode)

    @disease_event = mock_model(DiseaseEvent)
    @disease_mock = mock_model(Disease)
    @active_patient = mock_model(Participation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)


    @disease_mock.stub!(:disease_name).and_return("Bubonic,Plague")
    @event_status.stub!(:code_description).and_return('Open')
    @imported_from.stub!(:code_description).and_return('Utah')
    @udoh_case_status.stub!(:code_description).and_return('Confirmed')
    @lhd_case_status.stub!(:code_description).and_return('Confirmed')
    @outbreak_associated.stub!(:code_description).and_return('Yes')
    @hospitalized.stub!(:code_description).and_return('Yes')
    @died.stub!(:code_description).and_return('No')
    @pregnant.stub!(:code_description).and_return('Yes')
    @disease_event.stub!(:hospitalized).and_return(@hospitalized)
    @disease_event.stub!(:died).and_return(@died)
    @disease_event.stub!(:disease).and_return(@disease_mock)
    @disease_event.stub!(:date_diagnosed).and_return("2008-02-15")
    @disease_event.stub!(:disease_onset_date).and_return("2008-02-13")
    @specimen_source.stub!(:code_description).and_return('Tissue')
    @specimen_sent_to_uphl_yn.stub!(:code_description).and_return('Yes')

    @lab_result.stub!(:specimen_source).and_return(@specimen_source)
    @lab_result.stub!(:lab_result_text).and_return("Positive")
    @lab_result.stub!(:collection_date).and_return("2008-02-14")
    @lab_result.stub!(:lab_test_date).and_return("2008-02-15")
    @lab_result.stub!(:specimen_sent_to_uphl_yn).and_return(@specimen_sent_to_uphl_yn)

#    @participations_risk_factor.stub!(:food_handler_id).and_return(1402)
#    @participations_risk_factor.stub!(:group_living_id).and_return(1402)
#    @participations_risk_factor.stub!(:day_care_association_id).and_return(1402)
#    @participations_risk_factor.stub!(:healthcare_worker_id).and_return(1402)
#    @participations_risk_factor.stub!(:risk_factors).and_return("Obese")
#    @participations_risk_factor.stub!(:risk_factors_notes).and_return("300 lbs")
    @participations_risk_factor.stub!(:pregnant).and_return(@pregnant)
    @participations_risk_factor.stub!(:pregnancy_due_date).and_return(Date.parse('2008-10-12'))

    @active_patient.stub!(:participations_risk_factor).and_return(@participations_risk_factor)

    @event_1.stub!(:record_number).and_return("2008537081")
    @event_1.stub!(:event_name).and_return('Test')
    @event_1.stub!(:event_onset_date).and_return("2008-02-19")
    @event_1.stub!(:disease).and_return(@disease_event)
    @event_1.stub!(:type).and_return('MorbidityEvent')
    @event_1.stub!(:event_status).and_return(@event_status)
    @event_1.stub!(:imported_from).and_return(@imported_from)
    @event_1.stub!(:udoh_case_status).and_return(@udoh_case_status)
    @event_1.stub!(:lhd_case_status).and_return(@lhd_case_status)
    @event_1.stub!(:outbreak_associated).and_return(@outbreak_associated)
    @event_1.stub!(:outbreak_name).and_return("Test Outbreak")
    @event_1.stub!(:investigation_started_date).and_return("2008-02-05")
    @event_1.stub!(:investigation_completed_LHD_date).and_return("2008-02-08")
    @event_1.stub!(:review_completed_UDOH_date).and_return("2008-02-11")
    @event_1.stub!(:first_reported_PH_date).and_return("2008-02-07")
    @event_1.stub!(:results_reported_to_clinician_date).and_return("2008-02-08")
    @event_1.stub!(:MMWR_year).and_return("2008")
    @event_1.stub!(:MMWR_week).and_return("7")
    @event_1.stub!(:active_patient).and_return(@active_patient)
    @event_1.stub!(:clinicians).and_return([mock_clinician])
    @event_1.stub!(:contacts).and_return([mock_contact])
    @event_1.stub!(:answers).and_return(mock_answers)
    @event_1.stub!(:respond_to?).with(:each).and_return(false)
  end

  def mock_event_no_disease
    mock_event
    @event_1.stub!(:disease).and_return(nil)
  end

  def expected_record
    ['2008537081',
     'Test',
     '2008-02-19',
     'Bubonic Plague',
     'MorbidityEvent',
     'Utah',
     'Confirmed',
     'Yes',
     'Test Outbreak',
     'Open',
     '2008-02-05',
     '2008-02-08',
     '2008-02-11',
     '2008-02-07',
     '2008-02-08',
     '2008-02-13',
     '2008-02-15',
     'Yes',
     'No',
     'Yes',
     '2008-10-12',
     'Some Lab',
     'Tissue',
     'Positive',
     '2008-02-14',
     '2008-02-15',
     'Yes',
     'Joe Clinic',
     '(555)555-5555',
     '777 Some Address',
     '21',
     'Some City',
     '77777',
     'Some County',
     'Utah',
     'Some District',
     '2008',
     '7',
     'Newton Falls',
     'Summit',
     '55555',
     '11',
     'Male',
     'Not latino',
     'White',
     'English',
     'Numero uno',
     'No (answer three)'].join(',') + "\n"
  end
  
  def expected_record_no_disease
    ['2008537081',
     'Test',
     '2008-02-19',
     nil,
     'MorbidityEvent',
     'Utah',
     'Confirmed',
     'Yes',
     'Test Outbreak',
     'Open',
     '2008-02-05',
     '2008-02-08',
     '2008-02-11',
     '2008-02-07',
     '2008-02-08',
     nil,
     nil,
     nil,
     nil,
     'Yes',
     '2008-10-12',
     'Some Lab',
     'Tissue',
     'Positive',
     '2008-02-14',
     '2008-02-15',
     'Yes',
     'Joe Clinic',
     '(555)555-5555',
     '777 Some Address',
     '21',
     'Some City',
     '77777',
     'Some County',
     'Utah',
     'Some District',
     '2008',
     '7',
     'Newton Falls',
     'Summit',
     '55555',
     '11',
     'Male',
     'Not latino',
     'White',
     'English',
     'Numero uno',
     'No (answer three)'].join(',') + "\n"
  end

  def expected_headers_array
    %w(record_number
       event_name
       record_created_date
       disease
       event_type 
       imported_from
       UDOH_case_status
       outbreak_associated
       outbreak_name
       event_status
       investigation_started_date
       investigation_completed_LHD_date
       review_completed_UDOH_date
       first_reported_PH_date
       results_reported_to_clinician_date
       disease_onset_date
       date_diagnosed
       hospitalized
       died
       pregnant
       pregnancy_due_date
       laboratory_name
       specimen_source
       lab_result_text
       collection_date
       lab_test_date
       specimen_sent_to_uphl_yn
       clinician_name
       clinician_phone
       clinician_street
       clinician_unit
       clinician_city
       clinician_postal_code
       clinician_county
       clinician_state
       clinician_district
       MMWR_year
       MMWR_week
       contact_city
       contact_county
       contact_zip
       contact_age
       contact_birth_gender
       contact_ethnicity
       contact_race
       contact_primary_language
       short_name_1
       short_name_3)
  end

  it "should render csv data for 1 event" do
    mock_event
    render_events_csv(@event_1).should include(expected_record)
  end

  it "should not exclude disease fields if disease is nil" do
    mock_event_no_disease
    render_events_csv(@event_1).should include(expected_record_no_disease)
  end

  it "should render a header row" do
    mock_event
    exporter = Exporters::Csv::Event.new
    exporter.export_event(@event_1)
    exporter.headers.should == expected_headers_array
  end

  it "should replace commas with spaces to avoid creating fake columns" do
    mock_event
    render_events_csv(@event_1).should_not include('Bubonic,Plague')
  end

  it "should use the Event Csv export class" do
    mock_event
    Exporters::Csv::Event.export(@event_1).should include(expected_record)
  end
  
end
