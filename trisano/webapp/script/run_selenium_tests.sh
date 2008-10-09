#!/bin/bash

# Set TRISANO_URL to the url you want to test (e.g., http://localhost:8080)
#
# Run selenium RC prior to this script
#
# suggested that you run it the following way so that you can correlate tests to results:
# sh -v run_selenium_tests.sh 

ruby ../spec/uat/admin_console_selspec.rb
ruby ../spec/uat/admin_event_queues_selspec.rb
ruby ../spec/uat/admin_users_selspec.rb # this one requires login?
ruby ../spec/uat/basic_navigation_selspec.rb
ruby ../spec/uat/city_county_cmr_search_selspec.rb
ruby ../spec/uat/cmr_multiple_clinicians_selspec.rb
ruby ../spec/uat/cmr_multiple_contacts_selspec.rb
ruby ../spec/uat/cmr_multiple_diagnosing_health_facilities_selspec.rb
ruby ../spec/uat/cmr_multiple_hospitalized_health_facilities_selspec.rb
ruby ../spec/uat/cmr_multiple_lab_results_selspec.rb
ruby ../spec/uat/cmr_multiple_place_exposures_selspec.rb
ruby ../spec/uat/cmr_multiple_treatments_selspec.rb
ruby ../spec/uat/cmr_partial_treatment_selspec.rb
ruby ../spec/uat/cmr_print.rb
ruby ../spec/uat/cmr_record_id_logic_selspec.rb
ruby ../spec/uat/create_cmr_with_demographics_only_selspec.rb
ruby ../spec/uat/disease_admin_lead_in_questions_selspec.rb
ruby ../spec/uat/fb_admin_delete_follow_ups_selspec.rb
ruby ../spec/uat/fb_admin_edit_follow_ups_selspec.rb
ruby ../spec/uat/fb_contact_core_tab_config_selspec.rb
ruby ../spec/uat/fb_contact_disease_core_field_configs_selspec.rb
ruby ../spec/uat/fb_contact_investigation_form_config_selspec.rb
ruby ../spec/uat/fb_contact_multiples_core_field_configs_selspec.rb
ruby ../spec/uat/fb_contact_patient_address_core_field_configs_selspec.rb
ruby ../spec/uat/fb_contact_patient_core_field_configs_selspec.rb
ruby ../spec/uat/fb_contact_risk_factors_core_field_configs_selspec.rb
ruby ../spec/uat/fb_copy_forms_selspec.rb
ruby ../spec/uat/fb_event_core_tab_config.rb
ruby ../spec/uat/fb_fu_contact_disease_level.rb
ruby ../spec/uat/fb_fu_contact_event_level.rb
ruby ../spec/uat/fb_fu_contact_patient_address_selspec.rb
ruby ../spec/uat/fb_fu_contact_patient_core.rb
ruby ../spec/uat/fb_fu_contact_risk_factors.rb
ruby ../spec/uat/fb_fu_core_disease_level.rb
ruby ../spec/uat/fb_fu_core_event_level.rb
ruby ../spec/uat/fb_fu_core_patient_address_selspec.rb
ruby ../spec/uat/fb_fu_core_patient_core_selspec.rb
ruby ../spec/uat/fb_fu_core_reporting_level.rb
ruby ../spec/uat/fb_fu_core_risk_factors.rb
ruby ../spec/uat/fb_fu_place.rb
ruby ../spec/uat/fb_help_text_selspec.rb
ruby ../spec/uat/fb_invalid_core_field_config_selspec.rb
ruby ../spec/uat/fb_morbidity_core_tab_config_selspec.rb
ruby ../spec/uat/fb_morbidity_multiples_core_field_configs_selspec.rb
ruby ../spec/uat/fb_place_core_field_configs_selspec.rb
ruby ../spec/uat/fb_place_core_tab_config_selspec.rb
ruby ../spec/uat/fb_place_investigation_form_config_selspec.rb
ruby ../spec/uat/form_builder_admin_core_field_core_follow_up_selspec.rb
ruby ../spec/uat/form_builder_admin_core_follow_up_selspec.rb
ruby ../spec/uat/form_builder_admin_core_tab_follow_up_selspec.rb
ruby ../spec/uat/form_builder_admin_delete_elements_selspec.rb
ruby ../spec/uat/form_builder_admin_delete_groups_selspec.rb
ruby ../spec/uat/form_builder_admin_follow_up_selspec.rb
ruby ../spec/uat/form_builder_admin_invalid_follow_up_selspec.rb
ruby ../spec/uat/form_builder_admin_library_delete_selspec.rb
ruby ../spec/uat/form_builder_admin_question_alignment_selspec.rb
ruby ../spec/uat/form_builder_admin_selspec.rb
ruby ../spec/uat/form_builder_admin_value_set_library_selspec.rb
ruby ../spec/uat/form_builder_config_event_level_core_fields_selspec.rb
ruby ../spec/uat/form_builder_disease_core_field_configs_selspec.rb
ruby ../spec/uat/form_builder_investigator_single_form_selspec.rb
ruby ../spec/uat/form_builder_multiple_diseases_per_form_selspec.rb
ruby ../spec/uat/form_builder_patient_address_core_field_configs_selspec.rb
ruby ../spec/uat/form_builder_patient_core_field_configs_selspec.rb
ruby ../spec/uat/form_builder_reporting_core_field_configs_selspec.rb
ruby ../spec/uat/form_builder_risk_factor_core_field_configs_selspec.rb
ruby ../spec/uat/incremental_cmr_create_selspec.rb
ruby ../spec/uat/question_short_name_selspec.rb
ruby ../spec/uat/routing_and_controls_selspec.rb
ruby ../spec/uat/search_cmrs_for_existing_selspec.rb
ruby ../spec/uat/simple_cmr_create_selspec.rb
ruby ../spec/uat/tab_toggle_selspec.rb

