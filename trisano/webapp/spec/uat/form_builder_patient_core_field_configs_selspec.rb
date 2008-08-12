require File.dirname(__FILE__) + '/spec_helper'
 
describe 'form builder core-field questions' do
  
 # $dont_kill_browser = true
  
  before(:all) do
    @form_name = get_unique_name(2)  + " ln-fu-uat"
    @cmr_last_name = get_unique_name(1)  + " ln-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name" },
    @patient_last_name_before_question_text = get_unique_name(2)  + " ln-fu-uat"
    @patient_last_name_after_question_text = get_unique_name(2)  + " ln-fu-uat"
    
    @patient_last_name_before_answer = get_unique_name(2)  + " ln-fu-uat"
    @patient_last_name_after_answer = get_unique_name(2)  + " ln-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name" },
    @patient_first_name_before_question_text = get_unique_name(2)  + " fn-fu-uat"
    @patient_first_name_after_question_text = get_unique_name(2)  + " fn-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name" },
    @patient_before_middle_name_question_text = get_unique_name(2)  + " mn-fu-uat"
    @patient_after_middle_name_question_text = get_unique_name(2)  + " mn-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number" },
    @patient_before_street_number_question_text = get_unique_name(2)  + " sn-fu-uat"
    @patient_after_street_number_question_text = get_unique_name(2)  + " sn-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name" },
    @patient_before_street_name_question_text = get_unique_name(2)  + " sna-fu-uat"
    @patient_after_street_name_question_text = get_unique_name(2)  + " sna-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number" },
    @patient_before_unit_number_question_text = get_unique_name(2)  + " un-fu-uat"
    @patient_after_unit_number_question_text = get_unique_name(2)  + " un-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city" },
    @patient_before_city_question_text = get_unique_name(2)  + " c-fu-uat"
    @patient_after_city_question_text = get_unique_name(2)  + " c-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
    @patient_before_state_question_text = get_unique_name(2)  + " sta-fu-uat"
    @patient_after_state_question_text = get_unique_name(2)  + " sta-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
    @patient_before_county_question_text = get_unique_name(2)  + " c-fu-uat"
    @patient_after_county_question_text = get_unique_name(2)  + " c-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
    @patient_before_zip_question_text = get_unique_name(2)  + " z-fu-uat"
    @patient_after_zip_question_text = get_unique_name(2)  + " z-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth" },
    @patient_before_birth_date_question_text = get_unique_name(2)  + " bd-fu-uat"
    @patient_after_birth_date_question_text = get_unique_name(2)  + " bd-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
    @patient_before_age_question_text = get_unique_name(2)  + " a-fu-uat"
    @patient_after_age_question_text = get_unique_name(2)  + " a-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },,
    @patient_before_death_date_question_text = get_unique_name(2)  + " dd-fu-uat"
    @patient_after_death_date_question_text = get_unique_name(2)  + " dd-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
    @patient_before_gender_question_text = get_unique_name(2)  + " g-fu-uat"
    @patient_after_gender_question_text = get_unique_name(2)  + " g-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
    @patient_before_ethnicity_question_text = get_unique_name(2)  + " ln-fu-uat"
    @patient_after_ethnicity_question_text = get_unique_name(2)  + " ln-fu-uat"

    #      "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" },
    @patient_before_language_question_text = get_unique_name(2)  + " l-fu-uat"
    @patient_after_language_question_text = get_unique_name(2)  + " l-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant" },
    @patient_before_pregnant_question_text = get_unique_name(2)  + " p-fu-uat"
    @patient_after_pregnant_question_text = get_unique_name(2)  + " p-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "    Pregnancy due date" },
    @patient_before_pregnancy_due_date_question_text = get_unique_name(2)  + " pdd-fu-uat"
    @patient_after_pregnancy_due_date_question_text = get_unique_name(2)  + " pdd-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler" },
    @patient_before_food_handler_question_text = get_unique_name(2)  + " fh-fu-uat"
    @patient_after_food_handler_question_text = get_unique_name(2)  + " fh-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker" },
    @patient_before_healthcare_worker_question_text = get_unique_name(2)  + " hw-fu-uat"
    @patient_after_healthcare_worker_question_text = get_unique_name(2)  + " hw-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living" },
    @patient_before_group_living_question_text = get_unique_name(2)  + " gl-fu-uat"
    @patient_after_group_living_question_text = get_unique_name(2)  + " gl-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => " Day care association" },
    @patient_before_day_care_association_question_text = get_unique_name(2)  + " dc-fu-uat"
    @patient_after_day_care_association_question_text = get_unique_name(2)  + " dc-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation" },
    @patient_before_occupation_question_text = get_unique_name(2)  + " o-fu-uat"
    @patient_after_occupation_question_text = get_unique_name(2)  + " o-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors" },
    @patient_before_risk_factors_question_text = get_unique_name(2)  + " rf-fu-uat"
    @patient_after_risk_factors_question_text = get_unique_name(2)  + " rf-fu-uat"

    #      "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes" }
    @patient_before_risk_factor_notes_question_text = get_unique_name(2)  + " rfn-fu-uat"
    @patient_after_risk_factor_notes_question_text = get_unique_name(2)  + " rfn-fu-uat"

  end
  
  after(:all) do
    @form_name = nil
    @cmr_last_name = nil

    @patient_last_name_before_question_text = nil
    @patient_last_name_after_question_text = nil

    @patient_last_name_before_answer = nil
    @patient_last_name_after_answer = nil

    @patient_first_name_before_question_text = nil
    @patient_first_name_after_question_text = nil

    @patient_before_middle_name_question_text = nil
    @patient_after_middle_name_question_text = nil

    @patient_before_street_number_question_text = nil
    @patient_after_street_number_question_text = nil

    @patient_before_street_name_question_text = nil
    @patient_after_street_name_question_text = nil

    @patient_before_unit_number_question_text = nil
    @patient_after_unit_number_question_text = nil

    @patient_before_city_question_text = nil
    @patient_after_city_question_text = nil

    @patient_before_state_question_text = nil
    @patient_after_state_question_text = nil

    @patient_before_county_question_text = nil
    @patient_after_county_question_text = nil

    @patient_before_zip_question_text = nil
    @patient_after_zip_question_text = nil

    @patient_before_birth_date_question_text = nil
    @patient_after_birth_date_question_text = nil

    @patient_before_age_question_text = nil
    @patient_after_age_question_text = nil

    @patient_before_death_date_question_text = nil
    @patient_after_death_date_question_text = nil

    @patient_before_gender_question_text = nil
    @patient_after_gender_question_text = nil

    @patient_before_ethnicity_question_text = nil
    @patient_after_ethnicity_question_text = nil

    @patient_before_language_question_text = nil
    @patient_after_language_question_text = nil

    @patient_before_pregnant_question_text = nil
    @patient_after_pregnant_question_text = nil

    @patient_before_pregnancy_due_date_question_text = nil
    @patient_after_pregnancy_due_date_question_text = nil

    @patient_before_food_handler_question_text = nil
    @patient_after_food_handler_question_text = nil

    @patient_before_healthcare_worker_question_text = nil
    @patient_after_healthcare_worker_question_text = nil

    @patient_before_group_living_question_text = nil
    @patient_after_group_living_question_text = nil

    @patient_before_day_care_association_question_text = nil
    @patient_after_day_care_association_question_text = nil

    @patient_before_occupation_question_text = nil
    @patient_after_occupation_question_text = nil

    @patient_before_risk_factors_question_text = nil
    @patient_after_risk_factors_question_text = nil

    @patient_before_risk_factor_notes_question_text = nil
    @patient_after_risk_factor_notes_question_text = nil
  end


  it 'should create a new form with user-defined, core-field questions' do
    create_new_form_and_go_to_builder(@browser, @form_name, "African Tick Bite Fever", "All Jurisdictions").should be_true

    add_core_field_config(@browser, "Patient last name").should be_true
    add_question_to_before_core_field_config(@browser, "Patient last name", {:question_text =>@patient_last_name_before_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient last name", {:question_text =>@patient_last_name_after_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient first name").should be_true
    add_question_to_before_core_field_config(@browser, "Patient first name", {:question_text =>@patient_first_name_before_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient first name", {:question_text =>@patient_first_name_after_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient middle name").should be_true
    add_question_to_before_core_field_config(@browser, "Patient middle name", {:question_text =>@patient_before_middle_name_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient middle name", {:question_text =>@patient_after_middle_name_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient street number").should be_true
    add_question_to_before_core_field_config(@browser, "Patient street number", {:question_text =>@patient_before_street_number_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient street number", {:question_text =>@patient_after_street_number_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient street name").should be_true
    add_question_to_before_core_field_config(@browser, "Patient street name", {:question_text =>@patient_before_street_name_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient street name", {:question_text =>@patient_after_street_name_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient unit number").should be_true
    add_question_to_before_core_field_config(@browser, "Patient unit number", {:question_text =>@patient_before_unit_number_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient unit number", {:question_text =>@patient_after_unit_number_question_text, :data_type => "Single line text"}).should be_true

    add_core_field_config(@browser, "Patient city").should be_true
    add_question_to_before_core_field_config(@browser, "Patient city", {:question_text =>@patient_before_city_question_text, :data_type => "Single line text"}).should be_true
    add_question_to_after_core_field_config(@browser, "Patient city", {:question_text =>@patient_after_city_question_text, :data_type => "Single line text"}).should be_true


# Still to do...
#    #      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
#    @patient_before_state_question_text = get_unique_name(2)  + " sta-fu-uat"
#    @patient_after_state_question_text = get_unique_name(2)  + " sta-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
#    @patient_before_county_question_text = get_unique_name(2)  + " c-fu-uat"
#    @patient_after_county_question_text = get_unique_name(2)  + " c-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
#    @patient_before_zip_question_text = get_unique_name(2)  + " z-fu-uat"
#    @patient_after_zip_question_text = get_unique_name(2)  + " z-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth" },
#    @patient_before_birth_date_question_text = get_unique_name(2)  + " bd-fu-uat"
#    @patient_after_birth_date_question_text = get_unique_name(2)  + " bd-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
#    @patient_before_age_question_text = get_unique_name(2)  + " a-fu-uat"
#    @patient_after_age_question_text = get_unique_name(2)  + " a-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },,
#    @patient_before_death_date_question_text = get_unique_name(2)  + " dd-fu-uat"
#    @patient_after_death_date_question_text = get_unique_name(2)  + " dd-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
#    @patient_before_gender_question_text = get_unique_name(2)  + " g-fu-uat"
#    @patient_after_gender_question_text = get_unique_name(2)  + " g-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
#    @patient_before_ethnicity_question_text = get_unique_name(2)  + " ln-fu-uat"
#    @patient_after_ethnicity_question_text = get_unique_name(2)  + " ln-fu-uat"
#
#    #      "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" },
#    @patient_before_language_question_text = get_unique_name(2)  + " l-fu-uat"
#    @patient_after_language_question_text = get_unique_name(2)  + " l-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant" },
#    @patient_before_pregnant_question_text = get_unique_name(2)  + " p-fu-uat"
#    @patient_after_pregnant_question_text = get_unique_name(2)  + " p-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "    Pregnancy due date" },
#    @patient_before_pregnancy_due_date_question_text = get_unique_name(2)  + " pdd-fu-uat"
#    @patient_after_pregnancy_due_date_question_text = get_unique_name(2)  + " pdd-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler" },
#    @patient_before_food_handler_question_text = get_unique_name(2)  + " fh-fu-uat"
#    @patient_after_food_handler_question_text = get_unique_name(2)  + " fh-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker" },
#    @patient_before_healthcare_worker_question_text = get_unique_name(2)  + " hw-fu-uat"
#    @patient_after_healthcare_worker_question_text = get_unique_name(2)  + " hw-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living" },
#    @patient_before_group_living_question_text = get_unique_name(2)  + " gl-fu-uat"
#    @patient_after_group_living_question_text = get_unique_name(2)  + " gl-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => " Day care association" },
#    @patient_before_day_care_association_question_text = get_unique_name(2)  + " dc-fu-uat"
#    @patient_after_day_care_association_question_text = get_unique_name(2)  + " dc-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation" },
#    @patient_before_occupation_question_text = get_unique_name(2)  + " o-fu-uat"
#    @patient_after_occupation_question_text = get_unique_name(2)  + " o-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors" },
#    @patient_before_risk_factors_question_text = get_unique_name(2)  + " rf-fu-uat"
#    @patient_after_risk_factors_question_text = get_unique_name(2)  + " rf-fu-uat"
#
#    #      "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes" }
#    @patient_before_risk_factor_notes_question_text = get_unique_name(2)  + " rfn-fu-uat"
#    @patient_after_risk_factor_notes_question_text = get_unique_name(2)  + " rfn-fu-uat"
#

  end
    
  it "should publish the form and create an investigatable CMR" do
    publish_form(@browser).should be_true
    create_basic_investigatable_cmr(@browser, @cmr_last_name, "African Tick Bite Fever", "Bear River Health Department").should be_true
    edit_cmr(@browser).should be_true
  end
  
  it 'should place user-defined core-field questions on the correct tab' do
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @patient_last_name_before_question_text).should be_true
    assert_tab_contains_question(@browser, DEMOGRAPHICS, @patient_last_name_after_question_text).should be_true
  end
    
  it 'should allow answers to be saved' do
    click_core_tab(@browser, DEMOGRAPHICS)
    answer_investigator_question(@browser, @patient_last_name_before_question_text, @patient_last_name_before_answer).should be_true
    answer_investigator_question(@browser, @patient_last_name_after_question_text, @patient_last_name_after_answer).should be_true
    save_cmr(@browser).should be_true
    @browser.is_text_present(@patient_before_answer).should be_true
    @browser.is_text_present(@patient_after_answer).should be_true
  end
  
end
