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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/export/ibis.xml.builder" do

  before(:each) do
    assigns[:events_to_export] = [mock_ibis_event, mock_deleted_ibis_event]
    render "ibis_events/ibis.xml.builder"
  end

  it "should render valid XML IBIS output" do
    response.should have_tag("Table") do
      with_tag("ComdisRecord") do
        with_tag("RecordId", :text => "20080001")
        with_tag("UpdateFlag", :text => "0")
        with_tag("CaseCount", :text => "1")
        with_tag("Event", :text => "10000")
        with_tag("OnsetDate", :text => "01/03/2008")
        with_tag("DiagnosisDate", :text => "01/04/2008")
        with_tag("LabTestDate", :text => "01/02/2008")
        with_tag("ReportedDate", :text => "01/10/2008")
        with_tag("Zipcode", :text => "12345")
        with_tag("Age", :text => "30")
        with_tag("InvestigationHealthDistrict", :text => "1")
        with_tag("ResidenceHealthDistrict", :text => "99")
        with_tag("Ethnic", :text => "1")
        with_tag("Race", :text => ".")
        with_tag("Sex", :text => "1")
        with_tag("Status", :text => "1")
        with_tag("CreatedAt", :text => "01/15/2008")
        with_tag("Year", :text => "2008")
      end
      with_tag("ComdisRecord") do
        with_tag("RecordId", :text => "20080002")
        with_tag("UpdateFlag", :text => "1")
      end
    end
  end

end

def mock_ibis_event
  @gender_code = mock_model(Code)
  @gender_code.stub!(:the_code).and_return("M")

  @ethnic_code = mock_model(Code)
  @ethnic_code.stub!(:the_code).and_return("H")

  @state_code = mock_model(Code)
  @state_code.stub!(:the_code).and_return("C")

  @lhd_code = mock_model(Code)
  @lhd_code.stub!(:the_code).and_return("P")

  @person = mock_model(Person)
  @person.stub!(:last_name).and_return("Lastname")
  @person.stub!(:birth_date).and_return(Date.new(2008,1,1))
  @person.stub!(:birth_gender).and_return(@gender_code)
  @person.stub!(:ethnicity).and_return(@ethnic_code)

  @address = mock_model(Address)
  @address.stub!(:postal_code).and_return("12345")
  @address.stub!(:county).and_return(OpenStruct.new({:jusrisdiction => "whatever"}))

  entity = mock_model(PersonEntity)
  entity.stub!(:person).and_return(@person)
  entity.stub!(:races).and_return([])

  patient = mock_model(InterestedParty)
  patient.stub!(:person_entity).and_return(entity)

  @disease = mock_model(Disease)
  @disease.stub!(:cdc_code).and_return("10000")

  @disease_event = mock_model(DiseaseEvent)
  @disease_event.stub!(:disease_onset_date).and_return(Date.new(2008,1,3))
  @disease_event.stub!(:date_diagnosed).and_return(Date.new(2008,1,4))
  @disease_event.stub!(:disease).and_return(@disease)

  m = mock_model(MorbidityEvent)
  m.stub!(:type).and_return('MorbidityEvent')

  m.stub!(:id).and_return(1)
  m.stub!(:record_number).and_return("20080001")
  m.stub!(:event_onset_date).and_return(Date.new(2008,1,5))
  m.stub!(:age_info).and_return(OpenStruct.new({:in_years => 30}))

  m.stub!(:state_case_status).and_return(@state_code)
  m.stub!(:lhd_case_status).and_return(@lhd_code)

  m.stub!(:disease).and_return(@disease_event)
  m.stub!(:first_reported_PH_date).and_return(Date.new(2008,1,10))

  m.stub!(:sent_to_cdc).and_return(true)
  m.stub!(:deleted_at).and_return(nil)
  m.stub!(:created_at).and_return(Date.new(2008,1,15))

  @jurisdiction = mock_model(Place)
  @jurisdiction.stub!(:short_name).and_return("Bear River")

  m.stub!(:primary_jurisdiction).and_return(@jurisdiction)
  m.stub!(:interested_party).and_return(patient)
  m.stub!(:address).and_return(@address)

  @lab_result = mock_model(LabResult)
  @lab_result.stub!(:lab_name).and_return("LabName")
  @lab_result.stub!(:lab_result_text).and_return("Positive")
  @lab_result.stub!(:lab_test_date).and_return(Date.new(2008,1,2))
  m.stub!(:lab_results).and_return([@lab_result])

  m.stub!(:deleted_from_ibis?).and_return(false)

  m
end

def mock_deleted_ibis_event
  @state_code_2 = mock_model(Code)
  @state_code_2.stub!(:the_code).and_return("NC")

  m = mock_model(MorbidityEvent)
  m.stub!(:deleted_from_ibis?).and_return(true)
  m.stub!(:type).and_return('MorbidityEvent')
  m.stub!(:record_number).and_return("20080002")
  m.stub!(:state_case_status).and_return(@state_code_2)
  m.stub!(:deleted_at).and_return(nil)
  m
end
