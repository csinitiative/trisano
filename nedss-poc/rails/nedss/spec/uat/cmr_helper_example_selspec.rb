require File.dirname(__FILE__) + '/spec_helper' 
#$dont_kill_browser = true

describe "cmr helper example" do 
  before(:each) do
    #put any setup tasks here
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a cmr from a hash of field names and values" do 
    @cmr_fields = {
              # Patient fields
              "event_active_patient__active_primary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_street_number" => "123",
              "event_active_patient__active_primary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_unit_number" => "2",
              "event_active_patient__active_primary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_active_patient__active_primary_entity__address_postal_code" => "84601",
              "event_active_patient__active_primary_entity__person_birth_date" => "1/1/1974",
              "event_active_patient__active_primary_entity__person_approximate_age_no_birthday" => "22",
              "event_active_patient__active_primary_entity__person_date_of_death" => "1/1/1974",
              "event_active_patient__active_primary_entity__telephone_area_code" => "801",
              "event_active_patient__active_primary_entity__telephone_phone_number" => "555-7894",
              "event_active_patient__active_primary_entity__telephone_extension" => "147",
              "event_active_patient__active_primary_entity__person_birth_gender_id" => "Female",
              "event_active_patient__active_primary_entity__person_ethnicity_id" => "Not Hispanic or Latino",
              "event_active_patient__active_primary_entity__person_primary_language_id" => "Hmong",
              "event_active_patient__active_primary_entity_race_ids" => "Asian",
              "event_active_patient__active_primary_entity__address_county_id" => "Beaver",
              "event_active_patient__active_primary_entity__address_state_id" => "Utah",
              #Disease fields
              "event_disease_disease_onset_date" => "1/1/1974",
              "event_disease_date_diagnosed" => "1/1/1974",
              "event_disease_disease_id" => "Amebiasis",
              #Status fields
              "event_disease_died_id" => "Yes",
              "event_imported_from_id" => "Utah",
              #Hospital fields
              "event_hospitalized_health_facility__hospitals_participation_admission_date" => "1/1/1974",
              "event_hospitalized_health_facility__hospitals_participation_discharge_date" => "1/1/1974",
              "event_disease_hospitalized_id" => "Yes",
              "event_hospitalized_health_facility_secondary_entity_id" => "Alta View Hospital",
              #Diagnosis field
              "event_diagnosing_health_facility_secondary_entity_id" => "Alta View Hospital",
              #Treatment fields
              "event_active_patient__participations_treatment_treatment_given_yn_id" => "Yes",
              "event_active_patient__participations_treatment_treatment" => NedssHelper.get_unique_name(1),
              #Clinician fields
              "event_clinician__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_street_number" => "456",
              "event_clinician__active_secondary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_unit_number" => "5141",
              "event_clinician__active_secondary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_clinician__active_secondary_entity__address_postal_code" => "84602",
              "event_clinician__active_secondary_entity__person_birth_date" => "1/1/1974",
              "event_clinician__active_secondary_entity__person_approximate_age_no_birthday" => "55",
              "event_clinician__active_secondary_entity__person_date_of_death" => "1/1/1974",
              "event_clinician__active_secondary_entity__telephone_area_code" => "501",
              "event_clinician__active_secondary_entity__telephone_phone_number" => "555-1645",
              "event_clinician__active_secondary_entity__telephone_extension" => "1645",
              "event_clinician__active_secondary_entity__person_birth_gender_id" => "Female",
              "event_clinician__active_secondary_entity__person_ethnicity_id" => "Hispanic or Latino",
              "event_clinician__active_secondary_entity_race_ids" => "American Indian",
              "event_clinician__active_secondary_entity__person_primary_language_id" => "Japanese",
              #lab result fields
              "event_lab_result_specimen_source_id" => "Blood",
              "event_lab_result_tested_at_uphl_yn_id" => "Yes",
              "event_lab_result_lab_result_text" => NedssHelper.get_unique_name(1),
              "event_lab_result_collection_date" => "1/1/1974",
              "event_lab_result_lab_test_date" => "1/1/1974",
              #contact fields
              "event_contact__active_secondary_entity__address_state_id" => "Alaska",
              "event_contact__active_secondary_entity__address_county_id" => "Davis",
              "event_contact__active_secondary_entity__person_birth_gender_id" => "Female",
              "event_contact__active_secondary_entity__person_ethnicity_id" => "Not Hispanic or Latino",
              "event_contact__active_secondary_entity_race_ids" => "American Indian",
              "event_contact__active_secondary_entity__person_primary_language_id" => "Italian",
              "event_contact__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__person_middle_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_street_number" => "7845",
              "event_contact__active_secondary_entity__address_street_name" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_unit_number" => "7788",
              "event_contact__active_secondary_entity__address_city" => NedssHelper.get_unique_name(1),
              "event_contact__active_secondary_entity__address_postal_code" => "87484",
              "event_contact__active_secondary_entity__person_birth_date" => "1/1/1974",
              "event_contact__active_secondary_entity__person_approximate_age_no_birthday" => "64",
              "event_contact__active_secondary_entity__person_date_of_death" => "1/1/1974",
              "event_contact__active_secondary_entity__telephone_area_code" => "840",
              "event_contact__active_secondary_entity__telephone_phone_number" => "555-7457",
              "event_contact__active_secondary_entity__telephone_extension" => "4557",
              #epidemiological fields
              "event_active_patient__participations_risk_factor_food_handler_id" => "Yes",
              "event_active_patient__participations_risk_factor_healthcare_worker_id" => "Yes",
              "event_active_patient__participations_risk_factor_group_living_id" => "Yes",
              "event_active_patient__participations_risk_factor_day_care_association_id" => "Yes",
              "event_active_patient__participations_risk_factor_pregnant_id" => "Yes",
              "event_active_patient__participations_risk_factor_pregnancy_due_date" => "1/1/1974",
              "event_active_patient__participations_risk_factor_risk_factors" => NedssHelper.get_unique_name(3),
              #Not sure why this doesn't work. For some reason rspec thinks this is a select, but it's a type...
              #"event_active_patient__participations_risk_factor_risk_factors_notes" => NedssHelper.get_unique_name(30),              
              #reporting info fields
              "event_active_reporter__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__telephone_area_code" => "901",
              "event_active_reporter__active_secondary_entity__telephone_phone_number" => "555-1452",
              "event_active_reporter__active_secondary_entity__telephone_extension" => "4777",
              "event_results_reported_to_clinician_date" => "1/1/1974",
              "model_auto_completer_tf" => NedssHelper.get_unique_name(2), #This is the reporting agency field...
              #Administrative fields
              "event_event_case_status_id" => "Confirmed",
              "event_outbreak_associated_id" => "Yes",
              "event_active_jurisdiction_secondary_entity_id" => "Out of State",
              "event_event_status_id" => "Investigation Complete",
              "event_investigation_LHD_status_id" => "Open",
              "event_event_onset_date" => "1/1/1974",
              "event_outbreak_name" => NedssHelper.get_unique_name(1),
              "event_investigation_started_date" => "1/1/1974",
              "event_investigation_completed_LHD_date" => "1/1/1974",
              "event_event_name" => NedssHelper.get_unique_name(1),
              "event_first_reported_PH_date" => "1/1/1974",
              "event_review_completed_UDOH_date" => "1/1/1974"             
             }
    @browser.open("/nedss/forms")
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    NedssHelper.set_fields(@browser, @cmr_fields)
    @browser.click('event_submit')
    @browser.wait_for_page_to_load($load_time)
  end
end














