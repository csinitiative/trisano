require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/new.html.erb" do

  before(:each) do
    
    @event = mock_event
    
    # Maybe move this all up to the common mocking helper
    @participation = mock_model(Participation)
    @primary_entity =  mock_person_entity
    @secondary_entity =  mock_person_entity

    @active_jurisdiction = mock_model(Participation)
    @active_reporting_agency = mock_model(Participation)
    @active_reporter = mock_model(Participation)
    @active_hospital = mock_model(Participation)
    @current_treatment = mock_model(ParticipationsTreatment)

    @hospitals_participation = mock_model(HospitalsParticipation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)

    @place = mock_model(Place)
    @person = mock_model(Person)
    
    @event.stub!(:active_patient).and_return(@participation)
    @event.stub!(:active_reporting_agency).and_return(@active_reporting_agency)
    @event.stub!(:active_jurisdiction).and_return(@active_jurisdiction)
    @event.stub!(:active_hospital).and_return(@active_hospital)
    @event.stub!(:active_reporter).and_return(@active_reporter)
#    @event.stub!(:current_treatment).and_return(@current_treatment)

    @place.stub!(:name).and_return("Joe's Lab")
    @place.stub!(:entity_id).and_return(1)

    @person.stub!(:first_name).and_return("Joe")
    @person.stub!(:last_name).and_return("Cool")

    @participation.stub!(:active_primary_entity).and_return(@primary_entity)
    @participation.stub!(:participations_treatment).and_return(@current_treatment)
    @participation.stub!(:participations_risk_factor).and_return(@participations_risk_factor)
    @secondary_entity.stub!(:place).and_return(@place)
    @secondary_entity.stub!(:person).and_return(@person)

    @active_jurisdiction.stub!(:secondary_entity_id).and_return(1)
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
    @participations_risk_factor.stub!(:risk_factors).and_return("Obese")
    @participations_risk_factor.stub!(:risk_factors_notes).and_return("300 lbs")
    
    @hospitals_participation.stub!(:admission_date).and_return(Date.parse("2008-02-15"))
    @hospitals_participation.stub!(:discharge_date).and_return(Date.parse("2009-02-15"))

    
    assigns[:event] = @event
    
  end
  
  def do_render
    render "/events/new.html.erb"
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
