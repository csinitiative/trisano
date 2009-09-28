<?php

require_once('../lib/trisano-web-api.php');
require_once('Console/Getopt.php');

class TrisanoWebApiCmr extends TrisanoWebApi {

  private $options = array();

  function parse_args($args, $options = array()) {
    $longopts  = array(
"help",
"first_name==",
"middle_name==",
"last_name==",
"parent_guardian==",
"birth_date==",
"approx_age_no_birthday==",
"birth_gender==",
"ethnicity==",
"race==",
"primary_language==",
"address_street_number==",
"address_street_name==",
"address_unit_number==",
"address_city==",
"address_state==",
"address_county==",
"address_postal_code==",
"telephone_location_type==",
"telephone_area_code==",
"telephone_number==",
"telephone_extension==",
"telephone_delete==",
"email_address==",
"disease==",
"disease_onset_date==",
"date_diagnosed==",
"hospitalized==",
"health_facility==",
"admission_date==",
"discharge==",
"medical_record_number==",
"died==",
"date_of_death==",
"pregnant==",
"pregnancy_due_date==",
"treatment_given_yn==",
"treatment==",
"treatment_date==",
"stop_treatment_date==",
"clinician_first_name==",
"clinician_middle_name==",
"clinician_last_name==",
"clinician_telephone_location_type==",
"clinician_telephone_area_code==",
"clinician_telephone_location_type==",
"clinician_telephone_area_code==",
"clinician_telephone_number==",
"clinician_telephone_extension==",
"clinician_telephone_delete==",
"lab_name==",
"lab_test_type==",
"lab_test_result==",
"lab_result_value==",
"lab_units==",
"lab_reference_range==",
"lab_test_status==",
"lab_specimen_source==",
"lab_specimen_collection_date==",
"lab_test_date==",
"lab_specimen_sent_to_state==",
"lab_comment==",
"contact_first_name==",
"contact_middle_name==",
"contact_last_name==",
"contact_disposition==",
"contact_type==",
"contact_telephone_location_type==",
"contact_telephone_area_code==",
"contact_telephone_number==",
"contact_telephone_extension==",
"contact_telephone_delete==",
"food_handler==",
"healthcare_worker==",
"group_living==",
"day_care_association==",
"occupation==",
"imported_from==",
"risk_factors==",
"risk_factors_notes==",
"other_data_1==",
"other_data_2==",
"reporter_first_name==",
"reporter_last_name==",
"reporter_telephone_area_code==",
"reporter_telephone_number==",
"reporter_telephone_extension==",
"results_reported_to_clinician_date==",
"first_reported_ph_date==",
"note==",
"lhd_case_status==",
"state_case_status==",
"outbreak_associated==",
"outbreak_name==",
"event_name==",
"jurisdiction_responsible_for_investigation==",
"acuity=="
    );
    $cg = new Console_Getopt();
    $this->options = $cg->getopt($args, null, $longopts);
    if (PEAR::isError($this->options)) {
      die ("Error in command line: " . $this->options->getMessage() . "\n");
    }
    if (count($this->options[0]) == 0) {
      $this->print_help();
      exit(0);
    }
  }

  function populate_form() {
    foreach ($this->options[0] as $o) {
      switch ($o[0]) {
        case '--help':
          $this->print_help();
          exit(0);
        case '--first_name':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][first_name]', $o[1]);
          break;
        case '--middle_name':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][middle_name]', $o[1]);
          break;
        case '--last_name':
          $this->get_menu_option_id('morbidity_event[disease_event_attributes][died_id]', 'Yes');
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][last_name]', $o[1]);
          break;
        case '--birth_date':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_date]', $o[1]);
          break;
        case '--parent_guardian':
          $this->browser->setField('morbidity_event[parent_guardian]', $o[1]);
          break;
        case '--approximate_age_no_birthday':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][approximate_age_no_birthday]', $o[1]);
          break;
        case '--birth_gender':
          $id = $this->get_option_id('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][approximate_age_no_birthday]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_gender_id]', $id);
          break;
        case '--address_street_number':
          $this->browser->setField('morbidity_event[address_attributes][street_number]', $o[1]);
          break;
        case '--address_street_name':
          $this->browser->setField('morbidity_event[address_attributes][street_name]', $o[1]);
          break;
        case '--address_unit_number':
          $this->browser->setField('morbidity_event[address_attributes][unit_number]', $o[1]);
          break;
        case '--address_city':
          $this->browser->setField('morbidity_event[address_attributes][city]', $o[1]);
          break;
        case '--address_postal_code':
          $this->browser->setField('morbidity_event[address_attributes][postal_code]', $o[1]);
          break;
        case '--telephone_area_code':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]', $o[1]);
          break;
        case '--telephone_number':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]', $o[1]);
          break;
        case '--telephone_extension':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]', $o[1]);
          break;
        case '--telephone_delete':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][_delete]', true);
          break;
        case '--email_address':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][email_address]', $o[1]);
          break;
        case '--disease_onset_date':
          $this->browser->setField('morbidity_event[disease_event_attributes][disease_onset_date]', $o[1]);
          break;
        case '--date_diagnosed':
          $this->browser->setField('morbidity_event[disease_event_attributes][date_diagnosed]', $o[1]);
          break;
        case '--admission_date':
          $this->browser->setField('morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][admission_date]', $o[1]);
          break;
        case '--discharge_date':
          $this->browser->setField('morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][discharge_date]', $o[1]);
          break;
        case '--medical_record_number':
          $this->browser->setField('morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][medical_record_number]', $o[1]);
          break;
        case '--date_of_death':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][date_of_death]', $o[1]);
          break;
        case '--pregnancy_due_date':
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][pregnancy_due_date]', $o[1]);
          break;
        case '--treatment':
          $this->browser->setField('morbidity_event[interested_party_attributes][treatments_attributes][0][treatment]', $o[1]);
        case '--treatment_date':
          $this->browser->setField('morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_date]', $o[1]);
          break;
        case '--stop_treatment_date':
          $this->browser->setField('morbidity_event[interested_party_attributes][treatments_attributes][0][stop_treatment_date]', $o[1]);
          break;
        case '--clinician_first_name':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][first_name]', $o[1]);
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]', 'clinician');
          break;
        case '--clinician_middle_name':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][middle_name]', $o[1]);
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]', 'clinician');
          break;
        case '--clinician_last_name':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][last_name]', $o[1]);
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]', 'clinician');
          break;
        case '--clinician_telephone_area_code':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][area_code]', $o[1]);
          break;
        case '--clinician_telephone_number':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][phone_number]', $o[1]);
          break;
        case '--clinician_telephone_extension':
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][extension]', $o[1]);
          break;
        case '--lab_name':
          $this->browser->setField('morbidity_event[labs_attributes][3][place_entity_attributes][place_attributes][name]', $o[1]);
          break;
        case '--lab_result_value':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][result_value]', $o[1]);
          break;
        case '--lab_units':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][units]', $o[1]);
          break;
        case '--lab_reference_range':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][reference_range]', $o[1]);
          break;
        case '--lab_specimen_collection_date':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][collection_date]', $o[1]);
          break;
        case '--lab_test_date':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][lab_test_date]', $o[1]);
          break;
        case '--lab_comment':
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][comment]', $o[1]);
          break;
        case '--contact_first_name':
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][first_name]', $o[1]);
          break;
        case '--contact_last_name':
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][last_name]', $o[1]);
          break;
        case '--contact_telephone_area_code':
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]', $o[1]);
          break;
        case '--contact_telephone_number':
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]', $o[1]);
          break;
        case '--contact_telephone_extension':
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]', $o[1]);
          break;
        case '--encounter_date':
          $this->browser->setField('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][encounter_date]', $o[1]);
          break;
        case '--encounter_description':
          $this->browser->setField('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][description]', $o[1]);
          break;
        case '--occupation':
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][occupation]', $o[1]);
          break;
        case '--risk_factors':
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors]', $o[1]);
          break;
        case '--risk_factors_notes':
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors_notes]', $o[1]);
          break;
        case '--other_data_1':
          $this->browser->setField('morbidity_event[other_data_1]', $o[1]);
          break;
        case '--other_data_2':
          $this->browser->setField('morbidity_event[other_data_2]', $o[1]);
          break;
        case '--reporter_first_name':
          $this->browser->setField('morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][first_name]', $o[1]);
          break;
        case '--reporter_last_name':
          $this->browser->setField('morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][last_name]', $o[1]);
          break;
        case '--reporter_telephone_area_code':
          $this->browser->setField('morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][area_code]', $o[1]);
          break;
        case '--reporter_telephone_number':
          $this->browser->setField('morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][phone_number]', $o[1]);
          break;
        case '--reporter_telephone_extension':
          $this->browser->setField('morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][extension]', $o[1]);
          break;
        case '--results_reported_to_clinician_date':
          $this->browser->setField('morbidity_event[results_reported_to_clinician_date]', $o[1]);
          break;
        case '--first_reported_ph_date':
          $this->browser->setField('morbidity_event[first_reported_PH_date]', $o[1]);
          break;
        case '--note':
          $this->browser->setField('morbidity_event[notes_attributes][0][note]', $o[1]);
          break;
        case '--outbreak_name':
          $this->browser->setField('morbidity_event[outbreak_name]', $o[1]);
          break;
        case '--event_name':
          $this->browser->setField('morbidity_event[event_name]', $o[1]);
          break;
        case '--acuity':
          $this->browser->setField('morbidity_event[acuity]', $o[1]);
          break;
        case '--ethnicity':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][ethnicity_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][ethnicity_id]', $id);
          break;
        case '--race':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][person_entity_attributes][race_ids][]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][race_ids][]', $id);
          break;
        case '--primary_language':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][primary_language_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][primary_language_id]', $id);
          break;
        case '--address_state':
          $id = $this->get_menu_option_id('morbidity_event[address_attributes][state_id]', $o[1]);
          $this->browser->setField('morbidity_event[address_attributes][state_id]', $id);
          break;
        case '--address_county':
          $id = $this->get_menu_option_id('morbidity_event[address_attributes][county_id]', $o[1]);
          $this->browser->setField('morbidity_event[address_attributes][county_id]', $id);
          break;
        case '--telephone_entity_location_type':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]', $id);
          break;
        case '--disease':
          $id = $this->get_menu_option_id('morbidity_event[disease_event_attributes][disease_id]', $o[1]);
          $this->browser->setField('morbidity_event[disease_event_attributes][disease_id]', $id);
          break;
        case '--hospitalized':
          $id = $this->get_menu_option_id('morbidity_event[disease_event_attributes][hospitalized_id]', $o[1]);
          $this->browser->setField('morbidity_event[disease_event_attributes][hospitalized_id]', $id);
          break;
        case '--health_facility':
          $id = $this->get_menu_option_id('morbidity_event[hospitalization_facilities_attributes][0][secondary_entity_id]', $o[1]);
          $this->browser->setField('morbidity_event[hospitalization_facilities_attributes][0][secondary_entity_id]', $id);
          break;
        case '--died':
          $id = $this->get_menu_option_id('morbidity_event[disease_event_attributes][died_id]', $o[1]);
          $this->browser->setField('morbidity_event[disease_event_attributes][died_id]', $id);
          break;
        case '--pregnant':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][risk_factor_attributes][pregnant_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][pregnant_id]', $id);
          break;
        case '--treatment_given_yn':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]', $id);
          break;
        case '--clinician_telephone_entity_location_type':
          $id = $this->get_menu_option_id('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][entity_location_type_id]', $o[1]);
          $this->browser->setField('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][entity_location_type_id]', $id);
          break;
        case '--lab_test_type':
          $id = $this->get_menu_option_id('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_type_id]', $o[1]);
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_type_id]', $id);
          break;
        case '--lab_test_result':
          $id = $this->get_menu_option_id('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_result_id]', $o[1]);
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_result_id]', $id);
          break;
        case '--lab_test_status':
          $id = $this->get_menu_option_id('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_status_id]', $o[1]);
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][test_status_id]', $id);
          break;
        case '--lab_speciman_source':
          $id = $this->get_menu_option_id('morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_source_id]', $o[1]);
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_source_id]', $id);
          break;
        case '--lab_speciman_sent_to_state':
          $id = $this->get_menu_option_id('morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_sent_to_state_id]', $o[1]);
          $this->browser->setField('morbidity_event[labs_attributes][3][lab_results_attributes][0][specimen_sent_to_state_id]', $id);
          break;
        case '--contact_disposition':
          $id = $this->get_menu_option_id('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][disposition_id]', $o[1]);
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][disposition_id]', $id);
          break;
        case '--contact_type':
          $id = $this->get_menu_option_id('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][contact_type_id]', $o[1]);
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][contact_type_id]', $id);
          break;
        case '--contact_telephone_entity_location_type':
          $id = $this->get_menu_option_id('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]', $o[1]);
          $this->browser->setField('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]');
          break;
        case '--encounter_investigator':
          $id = $this->get_menu_option_id('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][user_id]', $o[1]);
          $this->browser->setField('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][user_id]', $id);
          break;
        case '--encounter_location':
          $id = $this->get_menu_option_id('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][encounter_location_type]', $o[1]);
          $this->browser->setField('morbidity_event[encounter_child_events_attributes][5][participations_encounter_attributes][encounter_location_type]', $id);
          break;
        case '--food_handler':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][risk_factor_attributes][food_handler_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][food_handler_id]', $id);
          break;
        case '--healthcare_worker':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][risk_factor_attributes][healthcare_worker_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][healthcare_worker_id]', $id);
          break;
        case '--group_living':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][risk_factor_attributes][group_living_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][group_living_id]', $id);
          break;
        case '--day_care_association':
          $id = $this->get_menu_option_id('morbidity_event[interested_party_attributes][risk_factor_attributes][day_care_association_id]', $o[1]);
          $this->browser->setField('morbidity_event[interested_party_attributes][risk_factor_attributes][day_care_association_id]', $id);
          break;
        case '--imported_from':
          $id = $this->get_menu_option_id('morbidity_event[imported_from_id]', $o[1]);
          $this->browser->setField('morbidity_event[imported_from_id]', $id);
          break;
        case '--lhd_case_status':
          $id = $this->get_menu_option_id('morbidity_event[lhd_case_status_id]', $o[1]);
          $this->browser->setField('morbidity_event[lhd_case_status_id]', $id);
          break;
        case '--state_case_status':
          $id = $this->get_menu_option_id('morbidity_event[state_case_status_id]', $o[1]);
          $this->browser->setField('morbidity_event[state_case_status_id]', $id);
          break;
        case '--outbreak_associated':
          $id = $this->get_menu_option_id('morbidity_event[outbreak_associated_id]', $o[1]);
          $this->browser->setField('morbidity_event[outbreak_associated_id]', $id);
          break;
        case '--jurisdiction_responsible_for_investigation':
          $id = $this->get_menu_option_id('morbidity_event[jurisdiction_attributes][secondary_entity_id]', $o[1]);
          $this->browser->setField('morbidity_event[jurisdiction_attributes][secondary_entity_id]', $id);
          break;
      }
    }
  }

  function print_help() {
    print "Usage: ./new_cmr.rb [options]

Options:
     --first_name=NAME                                   Person's first name.
     --middle_name=NAME                                  Person's middle name.
     --last_name=NAME                                    Person's last name.
     --parent_guardian=NAME                              Parent/guardian's full name.
     --birth_date=DATE                                   Person's birth date.  Most date formats work, including YYYY-MM-DD.
     --approx_age_no_birthday=AGE                        Approximate age if no birthday set.
     --birth_gender=GENDER                               Birth gender.
     --ethnicity=ETHNICITY                               Ethnicity.
     --race=RACE                                         Comma-delimited list of races.
     --primary_language=LANGUAGE                         Primary language.
     --address_street_number=NUMBER                      Address street number.
     --address_street_name=NAME                          Address street name.
     --address_unit_number=NUMBER                        Address unit number.
     --address_city=CITY                                 Address city.
     --address_state=STATE                               Address state.
     --address_county=COUNTY                             Address county.
     --address_postal_code=CODE                          Address postal code.
     --telephone_location_type=LOCATION                  Telephone location type.
     --telephone_area_code=CODE                          Telephone area code.
     --telephone_number=NUMBER                           Telephone number.
     --telephone_extension=NUMBER                        Telephone extension.
     --telephone_delete                                  Delete telephone.
     --email_address=EMAIL                               Email address.
     --email_address_delete                              Delete email address.
     --disease=NAME                                      Disease name.
     --disease_onset_date=DATE                           Disease onset date.
     --date_diagnosed=DATE                               Date diagnosed.
     --hospitalized=TEXT                                 Hospitalized? Yes, No, or Unknown.
     --health_facility=NAME                              Health facility name.
     --admission_date=DATE                               Health facility admission_date
     --discharge=DATE                                    Health facility discharge date.
     --medical_record_number=NUMBER                      Medical record number.
     --died=TEXT                                         Died? Yes, No, or Unknown.
     --date_of_death=DATE                                Date of death.
     --pregnant=TEXT                                     Pregnant? Yes, No, or Unknown.
     --pregnancy_due_date=DATE                           Pregnancy due date.
     --treatment_given_yn=TEXT                           Treatment given? Yes, No, or Unknown.
     --treatment=NAME                                    Treatment name.
     --treatment_date=DATE                               Treatment date.
     --stop_treatment_date=DATE                          Treatment stop date.
     --clinician_first_name=NAME                         Clinician first name.
     --clinician_middle_name=NAME                        Clinician middle name.
     --clinician_last_name=NAME                          Clinician last name
     --clinician_telephone_location_type LOCATION        Clinician telephone location type.
     --clinician_telephone_area_code=CODE                Clinician telephone area code.
     --clinician_telephone_number=NUMBER                 Clinician telephone number.
     --clinician_telephone_extension=NUMBER              Clinician telephone extension.
     --clinician_telephone_delete                        Delete clinician telephone.
     --lab_name=NAME                                     Lab name.
     --lab_test_type=NAME                                Lab test type.
     --lab_test_result=TEXT                              Lab test result.
     --lab_result_value=TEXT                             Lab result value.
     --lab_units=UNITS                                   Lab result units.
     --lab_reference_range=RANGE                         Lab reference range.
     --lab_test_status=STATUS                            Lab test status.
     --lab_specimen_source=SOURCE                        Lab specimen source.
     --lab_specimen_collection_date=DATE                 Lab specimen collection date.
     --lab_test_date=DATE                                Lab test date.
     --lab_specimen_sent_to_state=TEXT                   Sent to state? Yes, No, or Unknown.
     --lab_comment=TEXT                                  Lab comment.
     --contact_first_name=NAME                           Contact last name.
     --contact_middle_name=NAME                          Contact middle name.
     --contact_last_name=NAME                            Contact last name
     --contact_disposition=NAME                          Contact disposition.
     --contact_type=TYPE                                 Contact type.
     --contact_telephone_location_type=LOCATION          Contact telephone location type.
     --contact_telephone_area_code=CODE                  Contact telephone area code.
     --contact_telephone_number=NUMBER                   Contact telephone number.
     --contact_telephone_extension=NUMBER                Contact telephone extension.
     --contact_telephone_delete                          Delete contact telephone.
     --food_handler=TEXT                                 Food handler? Yes, No, Unknown.
     --healthcare_worker=TEXT                            Healthcare worker? Yes, No, Unknown.
     --group_living=TEXT                                 Group living? Yes, No, Unknown.
     --day_care_association=TEXT                         Day care association? Yes, No, Unknown.
     --occupation=TEXT                                   Occupation name.
     --imported_from=TEXT                                Imported from.
     --risk_factors=TEXT                                 Risk factors.
     --risk_factors_notes=TEXT                           Risk factors notes.
     --other_data_1=TEXT                                 Other data 1.
     --other_data_2=TEXT                                 Other data 2.
     --reporter_first_name=NAME                          Report first name.
     --reporter_last_name=NAME                           Report last name.
     --reporter_telephone_area_code=CODE                 Reporter telephone area code.
     --reporter_telephone_number=NUMBER                  Reporter telephone number.
     --reporter_telephone_extension=NUMBER               Reporter telephone extension.
     --results_reported_to_clinician_date=DATE           Results reported to clinician date.
     --first_reported_ph_date=DATE                       First reported to public health date.
     --note=TEXT                                         Event notes.
     --lhd_case_status=STATUS                            Local health department case status.
     --state_case_status=STATUS                          State case status.
     --outbreak_associated=TEXT                          Outbreak associated? Yes, No, Unknown.
     --outbreak_name=NAME                                Outbreak name.
     --event_name=NAME                                   Event name.
     --jurisdiction_responsible_for_investigation=TEXT   Jurisdiction responsible for investigation.
     --acuity                                            Acuity.
";
  }

  function get_menu_option_id($name, $value) {
    $page = $this->get_page();
    $dom = new DOMDocument();
    $dom->loadXML($page);
    $xpath = new DOMXPath($dom);
    $nodeList = $xpath->query(".//select[@name = '$name']/option");
    foreach($nodeList as $n) {
      if ($n->textContent == $value) {
        return $n->getAttribute('value');
      }
    }
    die("${name} with value ${value} not found in form");
  }

}
?>
