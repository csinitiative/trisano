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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/new.html.erb" do

  before(:each) do
    mock_user 
    @event = mock_event
     
    # Maybe move this all up to the common mocking helper
    @participation = mock_model(Participation)
    @primary_entity =  mock_person_entity
    @secondary_entity =  mock_person_entity
    @place_entity = mock_model(Entity)

    @primary_entity.stub!(:telephone_entities_locations).and_return([])
    
    @active_reporting_agency = mock_model(Participation)
    @active_reporter = mock_model(Participation)
    @active_hospital = mock_model(Participation)
    @lab = mock_model(Participation)
    @current_treatment = mock_model(ParticipationsTreatment)

    @hospitals_participation = mock_model(HospitalsParticipation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)

    @place = mock_model(Place)
    @person = mock_model(Person)

    @place_entity.stub!(:places).and_return([@place])
    #TODO: TGF REPLACE place_temp WITH place WHEN READY
    @place_entity.stub!(:place_temp).and_return(@place)
    
    @lab.stub!(:secondary_entity).and_return(@place_entity)
    @lab.stub!(:lab_results).and_return([])

    @event.stub!(:active_patient).and_return(@participation)
    @event.stub!(:active_reporting_agency).and_return(@active_reporting_agency)
    
    @event.stub!(:labs).and_return([@lab])
    @event.stub!(:active_hospital).and_return(@active_hospital)
    @event.stub!(:active_reporter).and_return(@active_reporter)
    @event.stub!(:under_investigation?).and_return(false)
    @event.stub!(:reopened?).and_return(false)
    @event.stub!(:contacts).and_return([])
    @event.stub!(:clinicians).and_return([])
    @event.stub!(:place_exposures).and_return([])
    event_type = 'MorbidityEvent'
    event_type.stub!(:underscore).and_return(event_type.underscore)
    @event.stub!(:type).and_return(event_type)
    
    @diagnosing_health_facility = mock_model(Participation)
    @diagnosing_health_facility.stub!(:role_id).and_return(199)
    @event.stub!(:diagnosing_health_facility).and_return(@diagnosing_health_facility)
    @event.stub!(:diagnosing_health_facilities).and_return([])
    
    @hospitalization_health_facility = mock_model(Participation)
    @hospitalization_health_facility.stub!(:role_id).and_return(190)
    @event.stub!(:hospitalized_health_facility).and_return(@hospitalization_health_facility)
    @event.stub!(:hospitalized_health_facilities).and_return([])
    
    @place.stub!(:name).and_return("Joe's Lab")
    @place.stub!(:entity_id).and_return(1)
    @place.stub!(:entity_id).and_return(1)
    @place.stub!(:id=).and_return(1)

    @person.stub!(:first_name).and_return("Joe")
    @person.stub!(:last_name).and_return("Cool")

    @participation.stub!(:active_primary_entity).and_return(@primary_entity)
    @participation.stub!(:secondary_entity).and_return(@secondary_entity)
    @participation.stub!(:participations_treatment).and_return(@current_treatment)
    @participation.stub!(:participations_risk_factor).and_return(@participations_risk_factor)
    @participation.stub!(:participations_treatments).and_return([])
    @secondary_entity.stub!(:place).and_return(@place)
    @secondary_entity.stub!(:person).and_return(@person)
    
    
    @active_reporting_agency.stub!(:active_secondary_entity).and_return(@secondary_entity)
    @active_reporter.stub!(:active_secondary_entity).and_return(@secondary_entity)
    @active_hospital.stub!(:secondary_entity_id).and_return(13)
    @active_hospital.stub!(:hospitals_participation).and_return(@hospitals_participation)
    @current_treatment.stub!(:treatment).and_return("Some pills")
    @current_treatment.stub!(:treatment_given_yn_id).and_return(1402)
    @participations_risk_factor.stub!(:food_handler_id).and_return(1402)
    @participations_risk_factor.stub!(:healthcare_worker_id).and_return(1402)
    @participations_risk_factor.stub!(:group_living_id).and_return(1402)
    @participations_risk_factor.stub!(:day_care_association_id).and_return(1402)
    @participations_risk_factor.stub!(:pregnant_id).and_return(1402)
    @participations_risk_factor.stub!(:pregnancy_due_date).and_return(Date.parse('2009-10-02'))
    @participations_risk_factor.stub!(:occupation).and_return('Programmer')
    @participations_risk_factor.stub!(:risk_factors).and_return("Obese")
    @participations_risk_factor.stub!(:risk_factors_notes).and_return("300 lbs")
    
    @hospitals_participation.stub!(:admission_date).and_return(Date.parse("2008-02-15"))
    @hospitals_participation.stub!(:discharge_date).and_return(Date.parse("2009-02-15"))

    assigns[:event] = @event
    
  end
  
  def do_render
    render "/morbidity_events/new.html.erb"
  end

  it "should render new event form" do
    do_render
    response.should have_tag("form[action=?][method=post]", cmrs_path) do
    end
  end

  it "should have more tests" do
    #...
  end

end
