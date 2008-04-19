require 'rubygems'
require 'selenium'
require 'test/unit'

class FullCMRCreateWithConflictingDates < Test::Unit::TestCase
 NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://utah:arches@ut-nedss-dev.csinitiative.com'

  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleneseInterpreter.new("localhost", 4444, "*firefox", NEDSS_URL, 10000);
      @selenium.start
    end
    @selenium.set_context("test_full_c_m_r_create_with_conflicting_dates")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_full_c_m_r_create_with_conflicting_dates
    @selenium.open "/nedss/"
    @selenium.click "link=New CMR"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__person_last_name", "von Monster"
    @selenium.type "event_active_patient__active_primary_entity__person_first_name", "John"
    @selenium.type "event_active_patient__active_primary_entity__person_middle_name", "Boy"
    @selenium.type "event_active_patient__active_primary_entity__address_street_number", "23456"
    @selenium.type "event_active_patient__active_primary_entity__address_street_name", "Street With a Very Long Name"
    @selenium.type "event_active_patient__active_primary_entity__address_unit_number", "4444"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Nowhere"
    @selenium.type "event_active_patient__active_primary_entity__address_city", "Provo"
    @selenium.type "event_active_patient__active_primary_entity__address_postal_code", "8462"
    @selenium.type "event_active_patient__active_primary_entity__person_birth_date", "5/8/1948"
    @selenium.type "event_active_patient__active_primary_entity__person_date_of_death", "7/4/2008"
    @selenium.type "event_active_patient__active_primary_entity__person_approximate_age_no_birthday", "34"
    @selenium.click "//span[3]/img"
    @selenium.type "event_active_patient__active_primary_entity__telephone_area_code", "801"
    @selenium.type "event_active_patient__active_primary_entity__telephone_phone_number", "5551234"
    @selenium.type "event_active_patient__active_primary_entity__telephone_extension", "abcd"
    @selenium.select "event_active_patient__active_primary_entity__person_birth_gender_id", "label=Male"
    @selenium.select "event_active_patient__active_primary_entity__person_ethnicity_id", "label=Not Hispanic or Latino"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=White"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=White"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Black / African-American"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Black / African-American"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=American Indian"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=American Indian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Asian"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Asian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Alaskan Native"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Alaskan Native"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Native Hawaiian / Pacific Islander"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Alaskan Native"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Native Hawaiian / Pacific Islander"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Asian"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Alaskan Native"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=American Indian"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Asian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=Black / African-American"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=American Indian"
    @selenium.add_selection "event_active_patient__active_primary_entity_race_ids", "label=White"
    @selenium.remove_selection "event_active_patient__active_primary_entity_race_ids", "label=Black / African-American"
    @selenium.select "event_active_patient__active_primary_entity__person_primary_language_id", "label=Lao"
    @selenium.click "//li[2]/a/em"
    @selenium.select "event_disease_disease_id", "label=Cache Valley virus neuroinvasive disease"
    @selenium.type "event_disease_disease_onset_date", "4/1/2008"
    @selenium.type "event_disease_date_diagnosed", "4/4/2008"
    @selenium.select "event_disease_hospitalized_id", "label=Yes"
    @selenium.select "event_active_hospital_secondary_entity_id", "label=Orem Community Hospital"
    @selenium.type "event_active_hospital__hospitals_participation_discharge_date", "4/29/2008"
    @selenium.type "event_active_hospital__hospitals_participation_admission_date", "4/4/2008"
    @selenium.select "event_disease_died_id", "label=Yes"
    @selenium.select "event_imported_from_id", "label=Utah"
    @selenium.select "event_active_patient__participations_treatment_treatment_given_yn_id", "label=Yes"
    @selenium.type "event_active_patient__participations_treatment_treatment", "Hard liquor"
    @selenium.click "//li[3]/a/em"
    @selenium.select "event_lab_result_specimen_source_id", "label=Blood & Stool"
    @selenium.click "//div[3]/fieldset/div/fieldset/span[3]/img"
    @selenium.select "event_lab_result_tested_at_uphl_yn_id", "label=Yes"
    @selenium.type "event_active_patient__participations_risk_factor_pregnancy_due_date", "9/1/2007"
    @selenium.click "//li[4]/a/em"
    @selenium.select "event_active_patient__participations_risk_factor_food_handler_id", "label=Yes"
    @selenium.select "event_active_patient__participations_risk_factor_healthcare_worker_id", "label=Yes"
    @selenium.select "event_active_patient__participations_risk_factor_group_living_id", "label=Yes"
    @selenium.select "event_active_patient__participations_risk_factor_day_care_association_id", "label=Yes"
    @selenium.select "event_active_patient__participations_risk_factor_pregnant_id", "label=Yes"
    @selenium.type "event_active_patient__participations_risk_factor_risk_factors", "He's a man!!!"
    @selenium.type "event_active_patient__participations_risk_factor_risk_factors_notes", "You can't be a pregnant man..."
    @selenium.click "//li[5]/a/em"
    @selenium.type "event_active_reporter__active_secondary_entity__person_first_name", "Joe"
    @selenium.type "event_active_reporter__active_secondary_entity__person_last_name", "Nice Guy"
    @selenium.type "event_active_reporter__active_secondary_entity__telephone_area_code", "801"
    @selenium.type "event_active_reporter__active_secondary_entity__telephone_phone_number", "581"
    @selenium.type "event_active_reporter__active_secondary_entity__telephone_extension", "54444"
    @selenium.click "//fieldset[3]/img"
    @selenium.click "link=>"
    @selenium.click "//li[6]/a/em"
    @selenium.select "event_event_case_status_id", "label=Suspect"
    @selenium.select "event_event_case_status_id", "label=Chronic Carrier"
    @selenium.select "event_outbreak_associated_id", "label=Yes"
    @selenium.click "//div[6]/fieldset/div/fieldset[2]/span[3]/img"
    @selenium.select "event_investigation_LHD_status_id", "label=Open"
    @selenium.type "event_investigation_started_date", "4/1/2008"
    @selenium.type "event_investigation_completed_LHD_date", "4/30/2008"
    @selenium.type "event_first_reported_PH_date", "5/1/2008"
    @selenium.type "event_review_completed_UDOH_date", "5/2/2008"
    @selenium.type "event_event_name", "Not sure what this field means"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    begin
        assert @selenium.is_text_present("Extension must have 1 to 6 digits")
    rescue Test::Unit::AssertionFailedError
        @verification_errors << $!
    end
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "event_active_patient__active_primary_entity__telephone_extension", "1235"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
    @selenium.click "//li[2]/a/em"
    @selenium.click "//li[3]/a/em"
    @selenium.click "//li[4]/a/em"
    @selenium.click "//li[5]/a/em"
    @selenium.type "event_active_reporter__active_secondary_entity__telephone_phone_number", "5818888"
    @selenium.click "event_submit"
    @selenium.wait_for_page_to_load "30000"
  end
end
