# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
        # with_tag("LabTestDate", :text => "01/02/2008")
        with_tag("ReportedDate", :text => "01/10/2008")
        with_tag("Zipcode", :text => "12345")
        with_tag("Age", :text => "30")
        with_tag("InvestigationHealthDistrict", :text => "1")
        with_tag("ResidenceHealthDistrict", :text => "99")
        with_tag("Ethnic", :text => "1")
        with_tag("Race", :text => ".")
        with_tag("Sex", :text => "1")
        with_tag("Status", :text => "1")
        with_tag("Year", :text => "2008")
        with_tag("EventCreatedDate", :text => "01/15/2008")
      end
      with_tag("ComdisRecord") do
        with_tag("RecordId", :text => "20080002")
        with_tag("UpdateFlag", :text => "1")
      end
    end
  end

end

def mock_ibis_event

  age_type = ExternalCode.find_by_code_name_and_the_code("age_type", "0")

  {
    'event_id' => 1,
    'imported_from_id' => '',
    'first_reported_ph_date' => '2008-01-10',
    'age_at_onset' => '30',
    'age_type_id' => age_type.id,
    'event_created_at' => '2008-01-15 00:00:00',
    'record_number' => '20080001',
    'deleted_at' => '',
    'event_case_status_code' => 'C',
    'event_lhd_case_status' => 'P',
    'disease_cdc_code' => '10000',
    'disease_onset_date' => '2008-01-03',
    'disease_event_date_diagnosed' => '2008-01-04',
    'address_postal_code' => '12345',
    'address_county_code' => '',
    'residence_jurisdiction_short_name' => 'whatever',
    'investigation_jurisdiction_short_name' => 'Bear River',
    'interested_party_person_entity_id' => '',
    'interested_party_ethnicity_code' => 'H',
    'interested_party_sex_code' => 'M'
  }
end

def mock_deleted_ibis_event
    {
    'event_id' => 2,
    'imported_from_id' => '',
    'first_reported_ph_date' => '',
    'age_at_onset' => '',
    'age_type_id' => '',
    'event_created_at' => '',
    'record_number' => '20080002',
    'deleted_at' => '2008-01-03',
    'event_case_status_code' => 'NC',
    'event_lhd_case_status' => '',
    'disease_cdc_code' => '',
    'disease_onset_date' => '',
    'disease_event_date_diagnosed' => '',
    'address_postal_code' => '',
    'address_county_code' => '',
    'residence_jurisdiction_short_name' => '',
    'investigation_jurisdiction_short_name' => '',
    'interested_party_person_entity_id' => '',
    'interested_party_ethnicity_code' => '',
    'interested_party_sex_code' => ''
  }
end
