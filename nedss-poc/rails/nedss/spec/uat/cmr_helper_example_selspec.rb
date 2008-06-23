require File.dirname(__FILE__) + '/spec_helper' 
$dont_kill_browser = true

describe "cmr_helper_example_selspec" do 
  before(:all) do
    @attrs = {# Here are all the patient attrs, all of which are tested...
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
              "event_active_patient__active_primary_entity__address_state_id" => "Utah"

=begin              "event_disease_disease_onset_date" => "1/1/1974",
              "event_disease_date_diagnosed" => "1/1/1974",
              "event_active_hospital__hospitals_participation_admission_date" => "1/1/1974",
              "event_active_hospital__hospitals_participation_discharge_date" => "1/1/1974",
              "event_active_patient__participations_treatment_treatment" => NedssHelper.get_unique_name(1),
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
              "event_lab_result_lab_result_text" => NedssHelper.get_unique_name(10),
              "event_lab_result_collection_date" => "1/1/1974",
              "event_lab_result_lab_test_date" => "1/1/1974",
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
              "event_active_patient__participations_risk_factor_pregnancy_due_date" => "1/1/1974",
              "event_active_patient__participations_risk_factor_risk_factors" => NedssHelper.get_unique_name(1),
              "model_auto_completer_tf" => "1/1/1974",
              "event_active_reporter__active_secondary_entity__person_first_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__person_last_name" => NedssHelper.get_unique_name(1),
              "event_active_reporter__active_secondary_entity__telephone_area_code" => "901",
              "event_active_reporter__active_secondary_entity__telephone_phone_number" => "555-1452",
              "event_active_reporter__active_secondary_entity__telephone_extension" => "4777",
              "event_results_reported_to_clinician_date" => "1/1/1974",
              "event_event_onset_date" => "1/1/1974",
              "event_outbreak_name" => NedssHelper.get_unique_name(1),
              "event_investigation_started_date" => "1/1/1974",
              "event_investigation_completed_LHD_date" => "1/1/1974",
              "event_event_name" => NedssHelper.get_unique_name(1),
              "event_first_reported_PH_date" => "1/1/1974",
              "event_review_completed_UDOH_date" => "1/1/1974"   
=end           
             }
    
  end
  
  before(:each) do
    #put any setup tasks here
  end
  
  it "should create a cmr from a hash of field names and values" do 
    @browser.open("/nedss/forms")
    @browser.click("link=New CMR")
    @browser.wait_for_page_to_load($load_time)
    cmr_hash = Hash.new()
    NedssHelper.create_cmr(@browser, @attrs)
  end
  
end
