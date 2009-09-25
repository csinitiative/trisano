<?php

require_once('../lib/trisano-web-api.php');
require_once('Console/Getopt.php');

class TrisanoWebApiCmr extends TrisanoWebApi {

  private $options = array();

  function parse_args($args, $options = array()) {
    $longopts  = array(
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
  }

  function populate_form() {
    foreach ($this->options[0] as $o) {
      switch ($o[0]) {
        case '--first_name':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][first_name]', $o[1]);
          break;
        case '--middle_name':
          $this->browser->setField('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][middle_name]', $o[1]);
          break;
        case '--last_name':
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
      }
    }
  }

}
?>
