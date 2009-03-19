# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe Export::Csv do
  fixtures :csv_fields

  before(:each) do
    @event_hash = {
      :interested_party_attributes => {
        :person_entity_attributes => {
          :person_attributes => {
            :last_name =>"Green"
          }
        }
      }
    }
    # There are 7 races
    ExternalCode.stub!(:count).and_return(7)
  end

  it "should expose an export method that takes an event or a list of events and an optional proc" do
    lambda { Export::Csv.export(   MorbidityEvent.new(@event_hash)   )    }.should_not raise_error()
    lambda { Export::Csv.export( [ MorbidityEvent.new(@event_hash) ] )    }.should_not raise_error()
    lambda { Export::Csv.export( [ MorbidityEvent.new(@event_hash) ] ) { MorbidityEvent.new(@event_hash) } }.should_not raise_error()

    lambda { Export::Csv.export( Object.new) }.should raise_error(ArgumentError)
  end

  describe "when passed a single simple event" do
    it "should output event, contact, place, treatment, and lab result HEADERS on one line" do
      to_arry( Export::Csv.export( MorbidityEvent.new(@event_hash), :export_options => %w(labs treatments places contacts) ) ).first.should == event_header(:morbidity) + "," + lab_header + "," + treatment_header + "," + event_header(:place) + "," + event_header(:contact)
    end

    it "should output content for a simple event" do
      a = to_arry( Export::Csv.export( MorbidityEvent.new(@event_hash) ) )
      a.size.should == 2
      a[1].include?(@event_hash[:interested_party_attributes][:person_entity_attributes][:person_attributes][:last_name]).should be_true
    end
  end

  describe "when passed multiple simple events" do
    it "should iterate over each event" do
      second_person = "White"
      deleted_person = 'Gone'
      eh = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => second_person } } } }
      dh = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => deleted_person } } }, :deleted_at => Date.parse('2008-1-1')}

      e1 = MorbidityEvent.new(@event_hash)
      e2 = MorbidityEvent.new( eh )
      e3 = MorbidityEvent.new( dh )

      a = to_arry( Export::Csv.export( [e1, e3, e2] ) )
      a.size.should == 3
      a[1].include?(@event_hash[:interested_party_attributes][:person_entity_attributes][:person_attributes][:last_name]).should be_true
      a[2].include?(second_person).should be_true
    end
  end

  # Debt: Does not yet test contacts and places
  describe "when passed a complex (fully loaded) event" do
    it "should output the right information" do
      e = csv_mock_event(:morbidity)
      a = to_arry( Export::Csv.export( e, {:export_options => ["labs", "treatments"], :disease => csv_mock_disease } ) )      
      a[0].include?("disease_specific_morb_q").should be_true      
      a[1].should =~ /#{event_output(:morbidity, e, {:disease => csv_mock_disease}) + "," + lab_output + "," + treatment_output}/
    end
  end

end

def to_arry(string)
  a = []
  string.each { |line| a << line.chomp }
  a
end

def lab_header
  %w(lab_record_id
  lab_name
  lab_test_type
  lab_test_detail
  lab_result
  lab_reference_range
  lab_interpretation
  lab_specimen_source
  lab_collection_date
  lab_test_date
  lab_specimen_sent_to_uphl).join(",")
end

def treatment_header
  %w(treatment_record_id
    treatment_given
    treatment
    treatment_date).join(",")
end

def event_header(event_type)
  header_array = []
  lead_in = case event_type
            when :morbidity
              "patient"
            when :contact
              "contact"
            when :place
              "place"
            end

  header_array << "#{lead_in}_event_id"
  header_array << "#{lead_in}_record_number" if event_type != :place

  if event_type != :place
    header_array << "#{lead_in}_last_name"
    header_array << "#{lead_in}_first_name"
    header_array << "#{lead_in}_middle_name"
  else
    header_array << "place_name"
    header_array << "place_type"
    header_array << "place_date_of_exposure"
  end

  header_array << "#{lead_in}_address_street_number"
  header_array << "#{lead_in}_address_street_name"
  header_array << "#{lead_in}_address_unit_number"
  header_array << "#{lead_in}_address_city"
  header_array << "#{lead_in}_address_state"
  header_array << "#{lead_in}_address_county"
  header_array << "#{lead_in}_address_postal_code"
  
  if event_type != :place
    header_array << "#{lead_in}_birth_date"
    header_array << "#{lead_in}_approximate_age_no_birthdate"
    header_array << "#{lead_in}_age_at_onset_in_years"
  end

  header_array << "#{lead_in}_phone_area_code"
  header_array << "#{lead_in}_phone_phone_number"
  header_array << "#{lead_in}_phone_extension"

  if event_type != :place
    header_array << "#{lead_in}_birth_gender"
    header_array << "#{lead_in}_ethnicity"
    header_array << "#{lead_in}_race_1"
    header_array << "#{lead_in}_race_2"
    header_array << "#{lead_in}_race_3"
    header_array << "#{lead_in}_race_4"
    header_array << "#{lead_in}_race_5"
    header_array << "#{lead_in}_race_6"
    header_array << "#{lead_in}_race_7"
    header_array << "#{lead_in}_language"
  end

  if event_type == :contact
    header_array << "contact_disposition"
    header_array << "contact_type"
  end

  if event_type != :place
    header_array << "#{lead_in}_disease"
    header_array << "#{lead_in}_disease_onset_date"
    header_array << "#{lead_in}_date_diagnosed"
    header_array << "#{lead_in}_diagnostic_facility"
    header_array << "#{lead_in}_hospitalized"
    header_array << "#{lead_in}_hospitalization_facility"
    header_array << "#{lead_in}_hospital_admission_date"
    header_array << "#{lead_in}_hospital_discharge_date"
    header_array << "#{lead_in}_hospital_medical_record_no"
    header_array << "#{lead_in}_died"
    header_array << "#{lead_in}_date_of_death"
    header_array << "#{lead_in}_pregnant"
    header_array << "#{lead_in}_clinician_last_name"
    header_array << "#{lead_in}_clinician_first_name"
    header_array << "#{lead_in}_clinician_middle_name"
    header_array << "#{lead_in}_clinician_phone_area_code"
    header_array << "#{lead_in}_clinician_phone_phone_number"
    header_array << "#{lead_in}_clinician_phone_extension"
    header_array << "#{lead_in}_food_handler"
    header_array << "#{lead_in}_healthcare_worker"
    header_array << "#{lead_in}_group_living"
    header_array << "#{lead_in}_day_care_association"
    header_array << "#{lead_in}_occupation"
    header_array << "#{lead_in}_risk_factors"
    header_array << "#{lead_in}_risk_factors_notes"
    header_array << "#{lead_in}_imported_from"

    if event_type == :morbidity
      header_array << "patient_reporting_agency"
      header_array << "patient_reporter_last_name"
      header_array << "patient_reporter_first_name"
      header_array << "patient_reporter_phone_area_code"
      header_array << "patient_reporter_phone_phone_number"
      header_array << "patient_reporter_phone_extension"
      header_array << "patient_results_reported_to_clinician_date"
      header_array << "patient_first_reported_PH_date"
      header_array << "patient_event_onset_date"
      header_array << "patient_MMWR_week"
      header_array << "patient_MMWR_year"
      header_array << "patient_lhd_case_status"
      header_array << "patient_state_case_status"
      header_array << "patient_outbreak_associated"
      header_array << "patient_outbreak_name"
      header_array << "patient_event_name"
      header_array << "patient_jurisdiction_of_investigation"
      header_array << "patient_jurisdiction_of_residence"
      header_array << "patient_event_status"
      header_array << "patient_investigation_started_date"
      header_array << "patient_investigation_completed_lhd_date"
      header_array << "patient_review_completed_by_state_date"
      header_array << "patient_investigator"
      header_array << "patient_sent_to_cdc"
      header_array << "acuity"
      header_array << "other_data_1"
      header_array << "other_data_2"
    end
  end
  header_array << "#{lead_in}_event_created_date"
  header_array << "#{lead_in}_event_last_updated_date"
  header_array.join(",")
end

def event_output(event_type, m, options={})
  out = ""
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
  out << "#{m.age_info.in_years},"
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
    out << "#{m.state_case_status.code_description},"
    out << "#{m.outbreak_associated.code_description},"
    out << "#{m.outbreak_name},"
    out << "#{m.event_name},"
    out << "#{m.primary_jurisdiction.name},"
    out << '"",'
    out << "#{m.event_status},"
    out << "#{m.investigation_started_date},"
    out << "#{m.investigation_completed_LHD_date},"
    out << "#{m.review_completed_by_state_date},"
    out << "#{m.investigator.best_name},"
    out << "#{m.sent_to_cdc},"
    out << "#{m.acuity},"
    out << "#{m.other_data_1},"
    out << "#{m.other_data_2},"
    out << "#{m.created_at},"
    out << "#{m.updated_at},"

    if options[:disease]
      out << "#{m.answers[0].text_answer}"
    end
  end
end

def lab_output
  out = ""
  out << "#{@lab_result.id},"
  out << "#{@lab_result.lab_name},"
  out << "#{@lab_result.test_type},"
  out << "#{@lab_result.test_detail},"
  out << "#{@lab_result.lab_result_text},"
  out << "#{@lab_result.reference_range},"
  out << "#{@lab_result.interpretation.code_description},"
  out << "#{@lab_result.specimen_source.code_description},"
  out << "#{@lab_result.collection_date},"
  out << "#{@lab_result.lab_test_date},"
  out << "#{@lab_result.specimen_sent_to_uphl_yn.code_description}"
end

def treatment_output
  out = ""
  out << "#{@treatment.id},"
  out << "#{@treatment.treatment_given_yn.code_description},"
  out << "#{@treatment.treatment},"
  out << "#{@treatment.treatment_date}"
end

def csv_mock_event(event_type)

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

  entity = mock_model(PersonEntity)
  entity.stub!(:telephones).and_return([])
  entity.stub!(:person).and_return(@person)
  entity.stub!(:races).and_return([])

  @treatment = mock_model(ParticipationsTreatment)
  @treatment.stub!(:treatment_given_yn).and_return(simple_reference)
  @treatment.stub!(:treatment).and_return("Antibiotics")
  @treatment.stub!(:treatment_date).and_return("2008-02-01")

  @contact = mock_model(ParticipationsContact)
  @contact.stub!(:contact_type).and_return(simple_reference)
  @contact.stub!(:disposition).and_return(simple_reference)

  patient = mock_model(InterestedParty,
                       :person_entity => entity,
                       :treatments => [@treatment],
                       :risk_factor => nil)

  @disease = mock_model(DiseaseEvent)
  @disease.stub!(:disease).and_return(simple_reference)
  @disease.stub!(:disease_onset_date).and_return("2008-01-03")
  @disease.stub!(:date_diagnosed).and_return("2008-01-04")
  @disease.stub!(:hospitalized).and_return(simple_reference)
  @disease.stub!(:died).and_return(simple_reference)

  if event_type == :morbidity
    m = mock_model(MorbidityEvent,
                   :type => 'MorbidityEvent',
                   :answers => [mock_model(Answer, { :short_name => "morb_q", :text_answer => "morb_q answer"})])
  elsif event_type == :contact
    m = mock_model(ContactEvent)
    m.stub!(:type).and_return('ContactEvent')
    m.stub!(:participations_contact).and_return(@contact)
  else
    m = mock_model(PlaceEvent)
    m.stub!(:type).and_return('PlaceEvent')
  end

  m.stub!(:id).and_return(1)
  m.stub!(:address).and_return(nil)
  m.stub!(:record_number).and_return("20080001")
  m.stub!(:event_onset_date).and_return("2008-01-05")
  m.stub!(:read_attribute).with("MMWR_week").and_return(1)
  m.stub!(:read_attribute).with("MMWR_year").and_return(2008)
  m.stub!(:age_info).and_return(OpenStruct.new(:in_years => 30))

  m.stub!(:age_type).and_return(simple_reference)
  m.stub!(:imported_from).and_return(simple_reference)
  m.stub!(:lhd_case_status).and_return(simple_reference)
  m.stub!(:state_case_status).and_return(simple_reference)
  m.stub!(:outbreak_associated).and_return(simple_reference)
  m.stub!(:outbreak_name).and_return("an outbreak")

  m.stub!(:disease_event).and_return(@disease)
  m.stub!(:event_name).and_return("an event")
  m.stub!(:event_status).and_return("NEW")
  m.stub!(:investigation_started_date).and_return("2008-01-06")
  m.stub!(:investigation_completed_lhd_date).and_return("2008-01-07")
  m.stub!(:review_completed_by_state_date).and_return("2008-01-08")
  m.stub!(:results_reported_to_clinician_date).and_return("2008-01-09")
  m.stub!(:first_reported_PH_date).and_return("2008-01-10")
  m.stub!(:investigation_completed_LHD_date).and_return("2008-01-11")
  m.stub!(:created_at).and_return("2008-01-12")
  m.stub!(:updated_at).and_return("2008-01-13")

  m.stub!(:investigator).and_return(simple_reference)
  m.stub!(:sent_to_cdc).and_return(true)

  m.stub!(:primary_jurisdiction).and_return(simple_reference)
  m.stub!(:interested_party).and_return(patient)

  m.stub!(:place_exposures).and_return([])
  m.stub!(:safe_call_chain).and_return(nil)
  m.stub!(:labs).and_return([])
  m.stub!(:hospitalization_facilities).and_return([])
  m.stub!(:diagnostic_facilities).and_return([])
  m.stub!(:clinicians).and_return([])
  m.stub!(:contacts).and_return([])
  m.should_receive(:acuity).twice.and_return('Difficult')
  m.should_receive(:other_data_1).twice.and_return('First Other Data')
  m.should_receive(:other_data_2).twice.and_return('Second Other Data')
  m.should_receive(:deleted_at).and_return(nil)

  @lab_result = mock_model(LabResult)
  @lab_result.stub!(:lab_name).and_return("LabName")
  @lab_result.stub!(:test_type).and_return("Biopsy")
  @lab_result.stub!(:test_detail).and_return("Liver")
  @lab_result.stub!(:lab_result_text).and_return("Positive")
  @lab_result.stub!(:reference_range).and_return("Detected")
  @lab_result.stub!(:interpretation).and_return(simple_reference)
  @lab_result.stub!(:specimen_source).and_return(simple_reference)
  @lab_result.stub!(:collection_date).and_return("2008-02-01")
  @lab_result.stub!(:lab_test_date).and_return("2008-02-02")
  @lab_result.stub!(:specimen_sent_to_uphl_yn).and_return(simple_reference)
  m.stub!(:lab_results).and_return([@lab_result])

  m
end

def csv_mock_disease
  morbidity_question = mock_model(Question)
  morbidity_question.stub!(:short_name).and_return("morb_q")

  morbidity_form = mock_model(Form)
  morbidity_form.stub!(:exportable_questions).and_return([morbidity_question])

  d = mock_model(Disease)
  d.stub!(:live_forms).with("MorbidityEvent").and_return([morbidity_form])
  d.stub!(:live_forms).with("ContactEvent").and_return([])
  d.stub!(:live_forms).with("PlaceEvent").and_return([])
  
  d
end

def simple_reference 
  @reference ||= OpenStruct.new(
    :code_description => "a code",
    :best_name => "A Name",
    :disease_name => "A Disease",
    :name => "Another Name"
  )
end

