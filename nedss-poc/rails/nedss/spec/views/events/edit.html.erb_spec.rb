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
    @current_treatment = mock_model(ParticipationsTreatment)

    @hospitals_participation = mock_model(HospitalsParticipation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)

    @place = mock_model(Place)
    @person = mock_model(Person)
    @answer = mock_model(Answer)

    @event.stub!(:active_patient).and_return(@participation)
    @event.stub!(:active_reporting_agency).and_return(@active_reporting_agency)
    @event.stub!(:active_hospital).and_return(@active_hospital)
    @event.stub!(:active_reporter).and_return(@active_reporter)
    @event.stub!(:under_investigation?).and_return(false)
    @event.stub!(:reopened?).and_return(false)
    @event.stub!(:get_or_initialize_answer).and_return(@answer)
    @event.stub!(:form_references).and_return([])

    @place.stub!(:name).and_return("Joe's Lab")
    @place.stub!(:entity_id).and_return(1)

    @person.stub!(:first_name).and_return("Joe")
    @person.stub!(:last_name).and_return("Cool")

    @answer.stub!(:text_answer).and_return("Whatever")
    @answer.stub!(:question_id).and_return(1,2,3)

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

      @form = mock_model(Form)
      @base_element = mock_model(FormBaseElement)
      @view_element = mock_model(ViewElement)
      @section_element = mock_model(SectionElement)

      @question_element_1 = mock_model(QuestionElement)
      @question_element_2 = mock_model(QuestionElement)
      @question_element_3 = mock_model(QuestionElement)
      @question_1 = mock_model(Question)
      @question_2 = mock_model(Question)
      @question_3 = mock_model(Question)
      @value_set = mock_model(ValueSetElement)
      @value_1 = mock_model(ValueElement)
      @value_2 = mock_model(ValueElement)

      @form.stub!(:name).and_return("A form name")
      @form.stub!(:description).and_return("A form description")
      @form.stub!(:form_base_element).and_return(@base_element)
    
      @base_element.stub!(:children).and_return([@view_element])
      @view_element.stub!(:children).and_return([@section_element])
      @section_element.stub!(:name).and_return("Section Name")
      @section_element.stub!(:description).and_return("Section Description")
      @section_element.stub!(:children).and_return([@question_element_1, @question_element_2, @question_element_3])

      @question_element_1.stub!(:question).and_return(@question_1)
      @question_element_1.stub!(:form_id).and_return(1)
      @question_element_1.stub!(:children).and_return([])

      @question_element_2.stub!(:question).and_return(@question_2)
      @question_element_2.stub!(:form_id).and_return(1)
      @question_element_2.stub!(:children).and_return([])
      
      @question_element_3.stub!(:question).and_return(@question_3)
      @question_element_3.stub!(:form_id).and_return(1)
      @question_element_3.stub!(:children).and_return([@value_set])
      
      @value_set.stub!(:children).and_return([@value_1, @value_2])

      @question_1.stub!(:question_text).and_return("Que?")
      @question_1.stub!(:data_type).and_return(:single_line_text)
      @question_1.stub!(:size).and_return(10)

      @question_2.stub!(:question_text).and_return("Quoi?")
      @question_2.stub!(:data_type).and_return(:multi_line_text)

      @question_3.stub!(:question_text).and_return("Huh?")
      @question_3.stub!(:data_type).and_return(:drop_down)

      @value_1.stub!(:name).and_return("value 1")
      @value_2.stub!(:name).and_return("value 2")

      @form_reference = mock_model(FormReference)
      @form_reference.stub!(:form).and_return(@form)
      @form_reference.stub!(:form_id).and_return(1)
      @event.stub!(:form_references).and_return([@form_reference])

      @disease = mock_model(Disease)
      @disease.stub!(:disease_name).and_return("Anthrax")
      @disease_event = mock_model(DiseaseEvent, :null_object => true)
    end

    def initialize_full_form
      @base_element.should_receive(:pre_order_walk).and_yield(@view_element).
                                                    and_yield(@section_element).
                                                    and_yield(@question_element_1).
                                                    and_yield(@question_element_2).
                                                    and_yield(@question_element_3)

#      @view_element.stub!(:pre_order_walk).and_yield(@section_element)
#      @section_element.stub!(:pre_oder_walk).and_yield(@question_element_1).
    end

    it "should not render if CMR status is not 'under investigation or not reopened'" do
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(false)
      @user.stub!(:is_entitled_to_in?).and_return(true)
      do_render
      response.should_not have_tag("div#investigation_tab")
    end

    it "should not render if user does not have 'investigate' privilege" do
      @event.stub!(:under_investigation?).and_return(true)
      @user.stub!(:is_entitled_to_in?).and_return(false)
      do_render
      response.should_not have_tag("div#investigation_tab")
    end

    it "should render if CMR status is 'under investigation' and user has the 'investigate' privilege in the right jurisdiction" do
      @event.stub!(:under_investigation?).and_return(true)
      @event.stub!(:reopened?).and_return(false)
      @user.stub!(:is_entitled_to_in?).and_return(true)

      initialize_full_form

      do_render
      response.should have_tag("div#investigation_tab")
    end

    it "should render if CMR status is 'reopened' and user has the 'investigate' privilege in the right jurisdiction" do
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(true)
      @user.stub!(:is_entitled_to_in?).and_return(true)

      initialize_full_form

      do_render
      response.should have_tag("div#investigation_tab")
    end

    describe "the disease investigation form" do 
      it "should say 'no form available' if there is no form available" do
        @event.stub!(:form_references).and_return([])
        do_render
        response.should have_text(/No investigation forms exist for/)
      end

      it "should display a tab with the form name" do

        initialize_full_form

        do_render
        response.should have_tag("ul#sub_form_tabs") do
          with_tag("li") do
            with_tag("a[href=?]", "#form_#{@form.id}") do
              with_tag("em", /#{@form.name}/)
            end
          end
        end
      end

      it "should display the form description" do

        initialize_full_form

        do_render
        response.should have_tag("h2", /#{@form.description}/)
      end

      it "should display all widget types, properly named" do

        initialize_full_form

        do_render

        response.should have_tag("label", /#{@question_1.question_text}/) do
          with_tag("input#?", /event_answers_\d+_text_answer/)
          with_tag("input[name=?]", /event\[answers\]\[\d+\]\[text_answer\]/)
        end

        response.should have_tag("label", /#{@question_2.question_text}/) do
          with_tag("textarea#?", /event_answers_\d+_text_answer/)
          with_tag("textarea[name=?]", /event\[answers\]\[\d+\]\[text_answer\]/)
        end

        response.should have_tag("label", /#{@question_3.question_text}/) do
          with_tag("select#?", /event_answers_\d+_text_answer/) do
            with_tag("option", "value 1")
            with_tag("option", "value 2")
          end
          with_tag("select[name=?]", /event\[answers\]\[\d+\]\[text_answer\]/)
        end

      end
    end
  end
end
