require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/index.csv.haml" do
  before(:each) do

    @event_1 = mock_model(Event)
    @event_type = mock_model(Code)
    @event_status = mock_model(Code)
    @imported_from = mock_model(ExternalCode)
    @event_case_status =mock_model(Code)
    @outbreak_associated = mock_model(Code)
    @investigation_LHD_status = mock_model(Code)
    @hospitalized = mock_model(ExternalCode)
    @died = mock_model(ExternalCode)
    @pregnant = mock_model(ExternalCode)
    @specimen_source = mock_model(ExternalCode)
    @tested_at_uphl_yn = mock_model(ExternalCode)
    @pregant = mock_model(ExternalCode)

    @lab_result = mock_model(LabResult)
    @disease_event = mock_model(DiseaseEvent)
    @disease_mock = mock_model(Disease)
    @active_patient = mock_model(Participation)
    @participations_risk_factor = mock_model(ParticipationsRiskFactor)

    @disease_mock.stub!(:disease_name).and_return("Bubonic,Plague")
    @event_type.stub!(:code_description).and_return('ONS')
    @event_status.stub!(:code_description).and_return('Open')
    @imported_from.stub!(:code_description).and_return('Utah')
    @event_case_status.stub!(:code_description).and_return('Confirmed')
    @outbreak_associated.stub!(:code_description).and_return('Yes')
    @investigation_LHD_status.stub!(:code_description).and_return('Closed')
    @hospitalized.stub!(:code_description).and_return('Yes')
    @died.stub!(:code_description).and_return('No')
    @pregnant.stub!(:code_description).and_return('Yes')
    @disease_event.stub!(:hospitalized).and_return(@hospitalized)
    @disease_event.stub!(:died).and_return(@died)
    @disease_event.stub!(:disease).and_return(@disease_mock)
    @disease_event.stub!(:date_diagnosed).and_return("2008-02-15")
    @disease_event.stub!(:disease_onset_date).and_return("2008-02-13")
    @specimen_source.stub!(:code_description).and_return('Tissue')
    @tested_at_uphl_yn.stub!(:code_description).and_return('Yes')
    @lab_result.stub!(:specimen_source).and_return(@specimen_source)
    @lab_result.stub!(:lab_result_text).and_return("Positive")
    @lab_result.stub!(:collection_date).and_return("2008-02-14")
    @lab_result.stub!(:lab_test_date).and_return("2008-02-15")
    @lab_result.stub!(:tested_at_uphl_yn).and_return(@tested_at_uphl_yn)

    @participations_risk_factor.stub!(:pregnant).and_return(@pregnant)
    @participations_risk_factor.stub!(:pregnancy_due_date).and_return(Date.parse('2008-10-12'))

    @active_patient.stub!(:participations_risk_factor).and_return(@participations_risk_factor)

    @event_1.stub!(:record_number).and_return("2008537081")
    @event_1.stub!(:event_name).and_return('Test')
    @event_1.stub!(:event_onset_date).and_return("2008-02-19")
    @event_1.stub!(:disease).and_return(@disease_event)
    @event_1.stub!(:lab_result).and_return(@lab_result)
    @event_1.stub!(:event_type).and_return(@event_type)
    @event_1.stub!(:event_status).and_return(@event_status)
    @event_1.stub!(:imported_from).and_return(@imported_from)
    @event_1.stub!(:event_case_status).and_return(@event_case_status)
    @event_1.stub!(:outbreak_associated).and_return(@outbreak_associated)
    @event_1.stub!(:outbreak_name).and_return("Test Outbreak")
    @event_1.stub!(:investigation_LHD_status).and_return(@investigation_LHD_status)
    @event_1.stub!(:investigation_started_date).and_return("2008-02-05")
    @event_1.stub!(:investigation_completed_LHD_date).and_return("2008-02-08")
    @event_1.stub!(:review_completed_UDOH_date).and_return("2008-02-11")
    @event_1.stub!(:first_reported_PH_date).and_return("2008-02-07")
    @event_1.stub!(:results_reported_to_clinician_date).and_return("2008-02-08")
    @event_1.stub!(:MMWR_year).and_return("2008")
    @event_1.stub!(:MMWR_week).and_return("7")
    @event_1.stub!(:active_patient).and_return(@active_patient)

    @event_2 = @event_1

    assigns[:events] = [@event_1,@event_2]
  end

  it "should render a csv template of the events" do
    render "/events/index.csv.haml"
  end

  it "should render csv data for 2 items" do
    render "/events/index.csv.haml"
    response.should have_text(/2008537081,Test,2008-02-19,Bubonic Plague,ONS,Open,Utah,Confirmed,Yes,Test Outbreak,Closed,2008-02-05,2008-02-08,2008-02-11,2008-02-07,2008-02-08,2008-02-13,2008-02-15,Yes,No,Yes,2008-10-12,Tissue,Positive,2008-02-14,2008-02-15,Yes,2008,7\n2008537081,Test,2008-02-19,Bubonic Plague,ONS,Open,Utah,Confirmed,Yes,Test Outbreak,Closed,2008-02-05,2008-02-08,2008-02-11,2008-02-07,2008-02-08,2008-02-13,2008-02-15,Yes,No,Yes,2008-10-12,Tissue,Positive,2008-02-14,2008-02-15,Yes,2008,7$/)
  end

  it "should render a header column" do
    render "/events/index.csv.haml"
    response.should have_text(/^record_number,event_name,event_onset_date,disease,event_type,event_status,imported_from,event_case_status,outbreak_associated,outbreak_name,investigation_LHD_status,investigation_started_date,investigation_completed_LHD_date,review_completed_UDOH_date,first_reported_PH_date,results_reported_to_clinician_date,disease_onset_date,date_diagnosed,hospitalized,died,pregnant,pregnancy_due_date,specimen_source,lab_result_text,collection_date,lab_test_date,tested_at_uphl_yn,MMWR_year,MMWR_week/)
  end

  it "should render a csv" do
    render "/events/index.csv.haml"
    response.should have_text("record_number,event_name,event_onset_date,disease,event_type,event_status,imported_from,event_case_status,outbreak_associated,outbreak_name,investigation_LHD_status,investigation_started_date,investigation_completed_LHD_date,review_completed_UDOH_date,first_reported_PH_date,results_reported_to_clinician_date,disease_onset_date,date_diagnosed,hospitalized,died,pregnant,pregnancy_due_date,specimen_source,lab_result_text,collection_date,lab_test_date,tested_at_uphl_yn,MMWR_year,MMWR_week\n2008537081,Test,2008-02-19,Bubonic Plague,ONS,Open,Utah,Confirmed,Yes,Test Outbreak,Closed,2008-02-05,2008-02-08,2008-02-11,2008-02-07,2008-02-08,2008-02-13,2008-02-15,Yes,No,Yes,2008-10-12,Tissue,Positive,2008-02-14,2008-02-15,Yes,2008,7\n2008537081,Test,2008-02-19,Bubonic Plague,ONS,Open,Utah,Confirmed,Yes,Test Outbreak,Closed,2008-02-05,2008-02-08,2008-02-11,2008-02-07,2008-02-08,2008-02-13,2008-02-15,Yes,No,Yes,2008-10-12,Tissue,Positive,2008-02-14,2008-02-15,Yes,2008,7\n")
  end

  it "should replace commas in fields with spaces to avoid adding fake columns" do
    render "/events/index.csv.haml"
    response.should_not have_text(/Bubonic,Plague/)
    response.should have_text(/Bubonic Plague/)
  end
end
