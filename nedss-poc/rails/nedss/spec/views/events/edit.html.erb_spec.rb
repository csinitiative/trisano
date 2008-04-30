require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/edit.html.erb" do

  before(:each) do
    mock_user 
    @event = mock_event
     
    # Maybe move this all up to the common mocking helper
    @participation = mock_model(Participation)
    @primary_entity =  mock_person_entity
    @secondary_entity =  mock_person_entity
#    @jurisdiction_entity = mock_model(Entity, :to_param => '1')
    
    @active_reporting_agency = mock_model(Participation)
    @active_reporter = mock_model(Participation)
    @active_hospital = mock_model(Participation)
#    @active_jurisdiction = mock_model(Participation)
    @current_treatment = mock_model(ParticipationsTreatment)

    @hospitals_participation = mock_model(HospitalsParticipation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)

    @place = mock_model(Place)
    @person = mock_model(Person)

    @event.stub!(:active_patient).and_return(@participation)
    @event.stub!(:active_reporting_agency).and_return(@active_reporting_agency)
    @event.stub!(:active_hospital).and_return(@active_hospital)
    @event.stub!(:active_reporter).and_return(@active_reporter)
#    @event.stub!(:active_jurisdiction).and_return(@active_jurisdiction)
    @event.stub!(:under_investigation?).and_return(false)
    @event.stub!(:reopened?).and_return(false)
    # @event.stub!(:current_treatment).and_return(@current_treatment)

    @place.stub!(:name).and_return("Joe's Lab")
    @place.stub!(:entity_id).and_return(1)

    @person.stub!(:first_name).and_return("Joe")
    @person.stub!(:last_name).and_return("Cool")

    @participation.stub!(:active_primary_entity).and_return(@primary_entity)
    @participation.stub!(:participations_treatment).and_return(@current_treatment)
    @participation.stub!(:participations_risk_factor).and_return(@participations_risk_factor)
    @secondary_entity.stub!(:place).and_return(@place)
    @secondary_entity.stub!(:person).and_return(@person)
    
    @active_reporting_agency.stub!(:active_secondary_entity).and_return(@secondary_entity)
#    @active_jurisdiction.stub!(:active_secondary_entity).and_return(@jurisdiction)
#    @active_jurisdiction.stub!(:secondary_entity_id).and_return('1')

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
    render "/events/edit.html.erb"
  end

  it "should render the edit event form" do
    do_render
    response.should have_tag("form[action=?][method=post]", cmr_path(@event)) do
    end
  end

  it "should have more tests" do
    #...
  end

  describe "the disesase investigation tab" do 

    before(:each) do
      @event.stub!(:under_investigation?).and_return(true)
      @user.stub!(:is_entitled_to_in?).and_return(true)

      @investigation_form = mock_model(Form)
      @investigation_form.stub!(:name).and_return("A form name")
      @investigation_form.stub!(:description).and_return("A form description")
      assigns[:investigation_forms] = [@investigation_form]

      @disease = mock_model(Disease)
      @disease.stub!(:disease_name).and_return("Anthrax")
      @disease_event = mock_model(DiseaseEvent, :null_object => true)
    end

    it "should not render if CMR status is not 'under investigation or not reopened'" do
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(false)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      do_render
      response.should_not have_tag("div#investigation_form")
    end

    it "should not render if user does not have 'investigate' privilege" do
      @event.stub!(:under_investigation?).and_return(true)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      do_render
      response.should_not have_tag("div#investigation_form")
    end

    it "should render if CMR status is 'under investigation' and user has the 'investigate' privilege in the right jurisdiction" do
      @event.stub!(:under_investigation?).and_return(true)
      @event.stub!(:reopened?).and_return(false)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      do_render
      response.should have_tag("div#investigation_form")
    end

    it "should render if CMR status is 'reopened' and user has the 'investigate' privilege in the right jurisdiction" do
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(true)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      do_render
      response.should have_tag("div#investigation_form")
    end

    describe "the disease investigation form" do 
      it "should say 'no form available' if there is no form available" do
        assigns[:investigation_forms] = []
        do_render
        response.should have_text(/No investigation forms exist for/)
      end

      it "should display a tab with the form name" do
        do_render
        response.should have_tag("ul#tabs") do
          with_tag("li") do
            with_tag("a[href=?]", "#form_#{@investigation_form.id}") do
              with_tag("em", /#{@investigation_form.name}/)
            end
          end
        end
      end

      it "should display the form description" do
        do_render
        response.should have_tag("h3", /#{@investigation_form.description}/)
      end
    end
  end
end
