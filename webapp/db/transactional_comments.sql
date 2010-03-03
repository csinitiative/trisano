 COMMENT ON TABLE addresses IS 'Addresses of people and place entities';
 COMMENT ON COLUMN addresses.city IS NULL;
 COMMENT ON COLUMN addresses.county_id IS NULL;
 COMMENT ON COLUMN addresses.created_at IS NULL;
 COMMENT ON COLUMN addresses.entity_id IS 'The entity this address relates to';
 COMMENT ON COLUMN addresses.entity_location_type_id IS NULL; -- TODO
 COMMENT ON COLUMN addresses.event_id IS 'The event this address relates to';
 COMMENT ON COLUMN addresses.id IS 'Primary key';
 COMMENT ON COLUMN addresses.latitude IS NULL;
 COMMENT ON COLUMN addresses.location_id IS NULL; -- TODO
 COMMENT ON COLUMN addresses.longitude IS NULL;
 COMMENT ON COLUMN addresses.postal_code IS NULL;
 COMMENT ON COLUMN addresses.state_id IS NULL;
 COMMENT ON COLUMN addresses.street_name IS NULL;
 COMMENT ON COLUMN addresses.street_number IS NULL;
 COMMENT ON COLUMN addresses.unit_number IS NULL;
 COMMENT ON COLUMN addresses.updated_at IS NULL;
 
 COMMENT ON TABLE answers IS 'Answers to formbuilder questions';
 COMMENT ON COLUMN answers.code IS NULL; -- TODO
 COMMENT ON COLUMN answers.event_id IS 'The event associated with this answer';
 COMMENT ON COLUMN answers.export_conversion_value_id IS NULL; -- TODO
 COMMENT ON COLUMN answers.id IS 'Primary key';
 COMMENT ON COLUMN answers.question_id IS 'The question this answer relates to';
 COMMENT ON COLUMN answers.text_answer IS 'The value of this answer';

 -- TODO
 COMMENT ON TABLE attachments IS NULL;
 COMMENT ON COLUMN attachments.category IS NULL;
 COMMENT ON COLUMN attachments.content_type IS NULL;
 COMMENT ON COLUMN attachments.created_at IS NULL;
 COMMENT ON COLUMN attachments.db_file_id IS NULL;
 COMMENT ON COLUMN attachments.event_id IS NULL;
 COMMENT ON COLUMN attachments.filename IS NULL;
 COMMENT ON COLUMN attachments.height IS NULL;
 COMMENT ON COLUMN attachments.id IS 'Primary key';
 COMMENT ON COLUMN attachments.size IS NULL;
 COMMENT ON COLUMN attachments.updated_at IS NULL;
 COMMENT ON COLUMN attachments.width IS NULL;

 -- TODO
 COMMENT ON TABLE cdc_exports IS NULL;
 COMMENT ON COLUMN cdc_exports.column_name IS NULL;
 COMMENT ON COLUMN cdc_exports.export_column_name IS NULL;
 COMMENT ON COLUMN cdc_exports.id IS 'Primary key';
 COMMENT ON COLUMN cdc_exports.is_required IS NULL;
 COMMENT ON COLUMN cdc_exports.length_to_output IS NULL;
 COMMENT ON COLUMN cdc_exports.start_position IS NULL;
 COMMENT ON COLUMN cdc_exports.table_name IS NULL;
 COMMENT ON COLUMN cdc_exports.type_data IS NULL;

 COMMENT ON TABLE codes IS 'Codes system administrators cannot modify';
 COMMENT ON COLUMN codes.code_description IS 'Full text of code meaning';
 COMMENT ON COLUMN codes.code_name IS 'Short version of code';
 COMMENT ON COLUMN codes.id IS 'Primary key';
 COMMENT ON COLUMN codes.sort_order IS 'Integer for sorting related codes';
 COMMENT ON COLUMN codes.the_code IS 'The actual code';

 -- TODO
 COMMENT ON TABLE core_fields IS NULL;
 COMMENT ON COLUMN core_fields.can_follow_up IS NULL;
 COMMENT ON COLUMN core_fields.created_at IS NULL;
 COMMENT ON COLUMN core_fields.event_type IS NULL;
 COMMENT ON COLUMN core_fields.fb_accessible IS NULL;
 COMMENT ON COLUMN core_fields.field_type IS NULL;
 COMMENT ON COLUMN core_fields.help_text IS NULL;
 COMMENT ON COLUMN core_fields.id IS 'Primary key';
 COMMENT ON COLUMN core_fields.key IS NULL;
 COMMENT ON COLUMN core_fields.name IS NULL;
 COMMENT ON COLUMN core_fields.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE csv_fields IS NULL;
 COMMENT ON COLUMN csv_fields.created_at IS NULL;
 COMMENT ON COLUMN csv_fields.event_type IS NULL;
 COMMENT ON COLUMN csv_fields.export_group IS NULL;
 COMMENT ON COLUMN csv_fields.id IS 'Primary key';
 COMMENT ON COLUMN csv_fields.long_name IS NULL;
 COMMENT ON COLUMN csv_fields.short_name IS NULL;
 COMMENT ON COLUMN csv_fields.sort_order IS NULL;
 COMMENT ON COLUMN csv_fields.updated_at IS NULL;
 COMMENT ON COLUMN csv_fields.use_code IS NULL;
 COMMENT ON COLUMN csv_fields.use_description IS NULL;

 -- TODO
 COMMENT ON TABLE db_files IS NULL;
 COMMENT ON COLUMN db_files.created_at IS NULL;
 COMMENT ON COLUMN db_files.data IS NULL;
 COMMENT ON COLUMN db_files.id IS 'Primary key';
 COMMENT ON COLUMN db_files.updated_at IS NULL;

 COMMENT ON TABLE disease_events IS 'Linking table between diseases and events';
 COMMENT ON COLUMN disease_events.created_at IS NULL;
 COMMENT ON COLUMN disease_events.date_diagnosed IS NULL;
 COMMENT ON COLUMN disease_events.died_id IS NULL;
 COMMENT ON COLUMN disease_events.disease_id IS 'ID of the disease to which this entry relates';
 COMMENT ON COLUMN disease_events.disease_onset_date IS NULL;
 COMMENT ON COLUMN disease_events.event_id IS 'ID of the event to which this entry relates';
 COMMENT ON COLUMN disease_events.hospitalized_id IS NULL;
 COMMENT ON COLUMN disease_events.id IS 'Primary key';
 COMMENT ON COLUMN disease_events.updated_at IS NULL;

 COMMENT ON TABLE diseases IS 'The list of diseases';
 COMMENT ON COLUMN diseases.active IS NULL;
 COMMENT ON COLUMN diseases.cdc_code IS NULL; -- TODO
 COMMENT ON COLUMN diseases.contact_lead_in IS NULL; -- TODO
 COMMENT ON COLUMN diseases.disease_name IS NULL;
 COMMENT ON COLUMN diseases.id IS 'Primary key';
 COMMENT ON COLUMN diseases.place_lead_in IS NULL; -- TODO
 COMMENT ON COLUMN diseases.treatment_lead_in IS NULL; -- TODO

 -- TODO
 COMMENT ON TABLE diseases_export_columns IS NULL;
 COMMENT ON COLUMN diseases_export_columns.disease_id IS NULL;
 COMMENT ON COLUMN diseases_export_columns.export_column_id IS NULL;

 -- TODO
 COMMENT ON TABLE diseases_external_codes IS NULL;
 COMMENT ON COLUMN diseases_external_codes.disease_id IS NULL;
 COMMENT ON COLUMN diseases_external_codes.external_code_id IS NULL;

 COMMENT ON TABLE diseases_forms IS 'Table linking diseases to forms used for those diseases';
 COMMENT ON COLUMN diseases_forms.created_at IS NULL;
 COMMENT ON COLUMN diseases_forms.disease_id IS 'The disease being linked';
 COMMENT ON COLUMN diseases_forms.form_id IS 'The form being linked';
 COMMENT ON COLUMN diseases_forms.updated_at IS NULL;

 COMMENT ON TABLE email_addresses IS 'Email addresses for various entities';
 COMMENT ON COLUMN email_addresses.created_at IS NULL;
 COMMENT ON COLUMN email_addresses.email_address IS 'The actual address';
 COMMENT ON COLUMN email_addresses.entity_id IS 'The entity this address relates to';
 COMMENT ON COLUMN email_addresses.id IS 'Primary key';
 COMMENT ON COLUMN email_addresses.updated_at IS NULL;

 -- TODO -- can we drop this table?
 COMMENT ON TABLE encounters IS NULL;
 COMMENT ON COLUMN encounters.created_at IS NULL;
 COMMENT ON COLUMN encounters.event_id IS NULL;
 COMMENT ON COLUMN encounters.id IS 'Primary key';
 COMMENT ON COLUMN encounters.updated_at IS NULL;

 COMMENT ON TABLE entities IS 'Contains an entry for the people, places, and things in the database';
 COMMENT ON COLUMN entities.created_at IS NULL;
 COMMENT ON COLUMN entities.deleted_at IS NULL;
 COMMENT ON COLUMN entities.entity_type IS 'Can be "PersonEntity" or "PlaceEntity"';
 COMMENT ON COLUMN entities.entity_url_number IS NULL; -- TODO
 COMMENT ON COLUMN entities.id IS 'Primary key';
 COMMENT ON COLUMN entities.record_number IS NULL; -- TODO
 COMMENT ON COLUMN entities.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE event_queues IS NULL;
 COMMENT ON COLUMN event_queues.id IS 'Primary key';
 COMMENT ON COLUMN event_queues.jurisdiction_id IS NULL;
 COMMENT ON COLUMN event_queues.queue_name IS NULL;

 COMMENT ON TABLE events IS 'Contains occurrences of interest to the Health Department';
 COMMENT ON COLUMN events.acuity IS NULL; -- TODO
 COMMENT ON COLUMN events.age_at_onset IS NULL;
 COMMENT ON COLUMN events.age_type_id IS 'The unit the number in age_at_onset describes (years, months, etc.)';
 COMMENT ON COLUMN events.cdc_updated_at IS NULL; -- TODO
 COMMENT ON COLUMN events.created_at IS NULL;
 COMMENT ON COLUMN events.deleted_at IS NULL;
 COMMENT ON COLUMN events.event_name IS NULL; -- TODO
 COMMENT ON COLUMN events.event_onset_date IS NULL;
 COMMENT ON COLUMN events.event_queue_id IS NULL; -- TODO
 COMMENT ON COLUMN events."first_reported_PH_date" IS NULL;
 COMMENT ON COLUMN events.ibis_updated_at IS NULL;
 COMMENT ON COLUMN events.id IS 'Primary key';
 COMMENT ON COLUMN events.imported_from_id IS NULL; -- TODO
 COMMENT ON COLUMN events."investigation_completed_LHD_date" IS NULL;
 COMMENT ON COLUMN events."investigation_LHD_status_id" IS NULL;
 COMMENT ON COLUMN events.investigation_started_date IS NULL;
 COMMENT ON COLUMN events.investigator_id IS NULL;
 COMMENT ON COLUMN events.lhd_case_status_id IS NULL;
 COMMENT ON COLUMN events."MMWR_week" IS 'Week of Reporting, Morbidity and Mortality Weekly Report';
 COMMENT ON COLUMN events."MMWR_year" IS 'Year of Reporting, Morbidity and Mortality Weekly Report';
 COMMENT ON COLUMN events.other_data_1 IS NULL; -- TODO
 COMMENT ON COLUMN events.other_data_2 IS NULL; -- TODO
 COMMENT ON COLUMN events.outbreak_associated_id IS NULL;
 COMMENT ON COLUMN events.outbreak_name IS NULL;
 COMMENT ON COLUMN events.parent_guardian IS NULL;
 COMMENT ON COLUMN events.parent_id IS 'Non-morbidity events will use this field to point to the morbidity event from which they originate. They will keep this ID even when changed to morbidity events.';
 COMMENT ON COLUMN events.participations_contact_id IS NULL;
 COMMENT ON COLUMN events.participations_encounter_id IS NULL;
 COMMENT ON COLUMN events.participations_place_id IS NULL;
 COMMENT ON COLUMN events.record_number IS NULL; -- TODO
 COMMENT ON COLUMN events.results_reported_to_clinician_date IS NULL;
 COMMENT ON COLUMN events.review_completed_by_state_date IS NULL;
 COMMENT ON COLUMN events.sent_to_cdc IS NULL;
 COMMENT ON COLUMN events.sent_to_ibis IS NULL;
 COMMENT ON COLUMN events.state_case_status_id IS NULL;
 COMMENT ON COLUMN events.type IS 'Can be MorbidityEvent, ContactEvent, PlaceEvent, or EncounterEvent';
 COMMENT ON COLUMN events.undergone_form_assignment IS NULL; -- TODO
 COMMENT ON COLUMN events.updated_at IS NULL;
 COMMENT ON COLUMN events.workflow_state IS 'Description of the investigation''s state in the investigation workflow';

 -- TODO
 COMMENT ON TABLE export_columns IS NULL;
 COMMENT ON COLUMN export_columns.column_name IS NULL;
 COMMENT ON COLUMN export_columns.created_at IS NULL;
 COMMENT ON COLUMN export_columns.data_type IS NULL;
 COMMENT ON COLUMN export_columns.export_column_name IS NULL;
 COMMENT ON COLUMN export_columns.export_disease_group_id IS NULL;
 COMMENT ON COLUMN export_columns.export_name_id IS NULL;
 COMMENT ON COLUMN export_columns.id IS 'Primary key';
 COMMENT ON COLUMN export_columns.is_required IS NULL;
 COMMENT ON COLUMN export_columns.length_to_output IS NULL;
 COMMENT ON COLUMN export_columns.name IS NULL;
 COMMENT ON COLUMN export_columns.start_position IS NULL;
 COMMENT ON COLUMN export_columns.table_name IS NULL;
 COMMENT ON COLUMN export_columns.type_data IS NULL;
 COMMENT ON COLUMN export_columns.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE export_conversion_values IS NULL;
 COMMENT ON COLUMN export_conversion_values.created_at IS NULL;
 COMMENT ON COLUMN export_conversion_values.export_column_id IS NULL;
 COMMENT ON COLUMN export_conversion_values.id IS 'Primary key';
 COMMENT ON COLUMN export_conversion_values.sort_order IS NULL;
 COMMENT ON COLUMN export_conversion_values.updated_at IS NULL;
 COMMENT ON COLUMN export_conversion_values.value_from IS NULL;
 COMMENT ON COLUMN export_conversion_values.value_to IS NULL;

 -- TODO
 COMMENT ON TABLE export_disease_groups IS NULL;
 COMMENT ON COLUMN export_disease_groups.created_at IS NULL;
 COMMENT ON COLUMN export_disease_groups.id IS 'Primary key';
 COMMENT ON COLUMN export_disease_groups.name IS NULL;
 COMMENT ON COLUMN export_disease_groups.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE export_names IS NULL;
 COMMENT ON COLUMN export_names.created_at IS NULL;
 COMMENT ON COLUMN export_names.export_name IS NULL;
 COMMENT ON COLUMN export_names.id IS 'Primary key';
 COMMENT ON COLUMN export_names.updated_at IS NULL;

 COMMENT ON TABLE external_codes IS 'Codes system administrators are allowed to change';
 COMMENT ON COLUMN external_codes.code_description IS 'Long description of the code''s meaning';
 COMMENT ON COLUMN external_codes.code_name IS NULL;
 COMMENT ON COLUMN external_codes.created_at IS NULL;
 COMMENT ON COLUMN external_codes.id IS 'Primary key';
 COMMENT ON COLUMN external_codes.jurisdiction_id IS 'If not null, allows codes to be used only in certain jurisdictions';
 COMMENT ON COLUMN external_codes.live IS 'Is the code in active use';
 COMMENT ON COLUMN external_codes.next_ver IS NULL; -- TODO
 COMMENT ON COLUMN external_codes.previous_ver IS NULL; -- TODO
 COMMENT ON COLUMN external_codes.sort_order IS 'Gives an order to groups of related codes';
 COMMENT ON COLUMN external_codes.the_code IS 'The actual code';
 COMMENT ON COLUMN external_codes.updated_at IS NULL;

 COMMENT ON TABLE form_elements IS 'Questions on forms are grouped into form elements';
 COMMENT ON COLUMN form_elements.code IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.condition IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.core_path IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.created_at IS NULL;
 COMMENT ON COLUMN form_elements.description IS 'Description of this group of questions';
 COMMENT ON COLUMN form_elements.export_column_id IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.export_conversion_value_id IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.form_id IS 'Links this form element to the form of which it''s a part';
 COMMENT ON COLUMN form_elements.help_text IS NULL;
 COMMENT ON COLUMN form_elements.id IS 'Primary key';
 COMMENT ON COLUMN form_elements.is_active IS NULL;
 COMMENT ON COLUMN form_elements.is_condition_code IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.is_template IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.lft IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.name IS 'Name of this group of questions';
 COMMENT ON COLUMN form_elements.parent_id IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.rgt IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.template_id IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.tree_id IS NULL; -- TODO
 COMMENT ON COLUMN form_elements.type IS 'Can be AfterCoreFieldElement, BeforeCoreFieldElement, CoreFieldElement, CoreFieldElementContainer, CoreViewElement, CoreViewElementContainer, FollowUpElement, FormBaseElement, GroupElement, InvestigatorViewElementContainer, QuestionElement, SectionElement, ValueElement, ValueSetElement, or ViewElement';
 COMMENT ON COLUMN form_elements.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE form_references IS NULL;
 COMMENT ON COLUMN form_references.event_id IS NULL;
 COMMENT ON COLUMN form_references.form_id IS NULL;
 COMMENT ON COLUMN form_references.id IS 'Primary key';
 COMMENT ON COLUMN form_references.template_id IS NULL;

 COMMENT ON TABLE forms IS 'Describes each formbuilder form';
 COMMENT ON COLUMN forms.created_at IS NULL;
 COMMENT ON COLUMN forms.description IS NULL;
 COMMENT ON COLUMN forms.event_type IS 'The type of event this form relates to';
 COMMENT ON COLUMN forms.id IS 'Primary key';
 COMMENT ON COLUMN forms.is_template IS NULL; -- TODO
 COMMENT ON COLUMN forms.jurisdiction_id IS 'The jurisdiction this form should be used in';
 COMMENT ON COLUMN forms.name IS 'Long name for this form';
 COMMENT ON COLUMN forms.rolled_back_from_id IS NULL; -- TODO
 COMMENT ON COLUMN forms.short_name IS 'Short name for this form';
 COMMENT ON COLUMN forms.status IS 'Can be Archived, Inactive, Live, Not, Published, or Published';
 COMMENT ON COLUMN forms.template_id IS NULL; -- TODO
 COMMENT ON COLUMN forms.updated_at IS NULL;
 COMMENT ON COLUMN forms.version IS 'When forms are updated, their version number increments';

 COMMENT ON TABLE hospitals_participations IS 'Describes a hospitalization due to an event';
 COMMENT ON COLUMN hospitals_participations.admission_date IS NULL;
 COMMENT ON COLUMN hospitals_participations.created_at IS NULL;
 COMMENT ON COLUMN hospitals_participations.discharge_date IS NULL;
 COMMENT ON COLUMN hospitals_participations.hospital_record_number IS NULL;
 COMMENT ON COLUMN hospitals_participations.id IS 'Primary key';
 COMMENT ON COLUMN hospitals_participations.medical_record_number IS NULL;
 COMMENT ON COLUMN hospitals_participations.participation_id IS 'The participations entry related to this record';
 COMMENT ON COLUMN hospitals_participations.updated_at IS NULL;

 COMMENT ON TABLE lab_results IS 'Information about lab test results and specimens associated with a participation';
 COMMENT ON COLUMN lab_results.collection_date IS NULL;
 COMMENT ON COLUMN lab_results.created_at IS NULL;
 COMMENT ON COLUMN lab_results.id IS 'Primary key';
 COMMENT ON COLUMN lab_results.interpretation_id IS NULL;
 COMMENT ON COLUMN lab_results.lab_result_text IS NULL;
 COMMENT ON COLUMN lab_results.lab_test_date IS NULL;
 COMMENT ON COLUMN lab_results.participation_id IS 'The participation this lab result links to';
 COMMENT ON COLUMN lab_results.reference_range IS NULL; -- TODO
 COMMENT ON COLUMN lab_results.specimen_sent_to_uphl_yn_id IS NULL;
 COMMENT ON COLUMN lab_results.specimen_source_id IS NULL;
 COMMENT ON COLUMN lab_results.staged_message_id IS NULL; -- TODO
 COMMENT ON COLUMN lab_results.test_detail IS 'Further details about the test';
 COMMENT ON COLUMN lab_results.test_type IS 'The type of test performed';
 COMMENT ON COLUMN lab_results.updated_at IS NULL;

 -- TODO
 COMMENT ON TABLE notes IS NULL;
 COMMENT ON COLUMN notes.created_at IS NULL;
 COMMENT ON COLUMN notes.event_id IS NULL;
 COMMENT ON COLUMN notes.id IS 'Primary key';
 COMMENT ON COLUMN notes.note IS NULL;
 COMMENT ON COLUMN notes.note_type IS NULL;
 COMMENT ON COLUMN notes.struckthrough IS NULL;
 COMMENT ON COLUMN notes.updated_at IS NULL;
 COMMENT ON COLUMN notes.user_id IS NULL;

 COMMENT ON TABLE participations IS 'Associates entities of various types with events';
 COMMENT ON COLUMN participations.comment IS NULL; -- TODO -- unused?
 COMMENT ON COLUMN participations.created_at IS NULL;
 COMMENT ON COLUMN participations.event_id IS NULL;
 COMMENT ON COLUMN participations.id IS 'Primary key';
 COMMENT ON COLUMN participations.participation_status_id IS NULL;
 COMMENT ON COLUMN participations.primary_entity_id IS 'Points to the entity record of the patient related to this event';
 COMMENT ON COLUMN participations.secondary_entity_id IS 'Points to other entities related to this event, e.g. hospitalizations, lab results, clinicians';
 COMMENT ON COLUMN participations.type IS 'Can be AssociatedJurisdiction, Clinician, DiagnosticFacility, HospitalizationFacility, InterestedParty, InterestedPlace, Jurisdiction, Lab, Reporter, or ReportingAgency';
 COMMENT ON COLUMN participations.updated_at IS NULL;

 COMMENT ON TABLE participations_contacts IS 'Information specific to contact events, linked from events.participations_contact_id for all contact events';
 COMMENT ON COLUMN participations_contacts.contact_type_id IS NULL; -- TODO . Also, if this is a link to external_codes, make a foreign key
 COMMENT ON COLUMN participations_contacts.created_at IS NULL;
 COMMENT ON COLUMN participations_contacts.disposition_id IS 'Describes treatment details for this contact event'; -- TODO: Create foreign key
 COMMENT ON COLUMN participations_contacts.id IS 'Primary key';
 COMMENT ON COLUMN participations_contacts.updated_at IS NULL;

 COMMENT ON TABLE participations_encounters IS 'Information specific to encounter events, linked from events.participations_encounter_id for all encounter events';
 COMMENT ON COLUMN participations_encounters.created_at IS NULL;
 COMMENT ON COLUMN participations_encounters.description IS 'Description of encounter';
 COMMENT ON COLUMN participations_encounters.encounter_date IS NULL;
 COMMENT ON COLUMN participations_encounters.encounter_location_type IS 'The type of location where the encounter took place (e.g. clinic, school, etc.)';
 COMMENT ON COLUMN participations_encounters.id IS 'Primary key';
 COMMENT ON COLUMN participations_encounters.updated_at IS NULL;
 COMMENT ON COLUMN participations_encounters.user_id IS NULL; -- TODO

 COMMENT ON TABLE participations_places IS 'Information specific to place events, linked from events.participations_place_id for all place events.';
 COMMENT ON COLUMN participations_places.created_at IS NULL;
 COMMENT ON COLUMN participations_places.date_of_exposure IS NULL;
 COMMENT ON COLUMN participations_places.id IS 'Primary key';
 COMMENT ON COLUMN participations_places.updated_at IS NULL;

 COMMENT ON TABLE participations_risk_factors IS 'Describes risk factors associated with a particular patient and event';
 COMMENT ON COLUMN participations_risk_factors.created_at IS NULL;
 COMMENT ON COLUMN participations_risk_factors.day_care_association_id IS NULL;
 COMMENT ON COLUMN participations_risk_factors.food_handler_id IS NULL;
 COMMENT ON COLUMN participations_risk_factors.group_living_id IS NULL;
 COMMENT ON COLUMN participations_risk_factors.healthcare_worker_id IS NULL;
 COMMENT ON COLUMN participations_risk_factors.id IS 'Primary key';
 COMMENT ON COLUMN participations_risk_factors.occupation IS 'Description of the patient''s occupation';
 COMMENT ON COLUMN participations_risk_factors.participation_id IS 'The participation this record relates to';
 COMMENT ON COLUMN participations_risk_factors.pregnancy_due_date IS NULL;
 COMMENT ON COLUMN participations_risk_factors.pregnant_id IS NULL;
 COMMENT ON COLUMN participations_risk_factors.risk_factors IS 'Text description of other risk factors';
 COMMENT ON COLUMN participations_risk_factors.risk_factors_notes IS 'Further description of other risk factors';
 COMMENT ON COLUMN participations_risk_factors.updated_at IS NULL;

 COMMENT ON TABLE participations_treatments IS 'Links treatments with participations and the events they''re associated with';
 COMMENT ON COLUMN participations_treatments.created_at IS NULL;
 COMMENT ON COLUMN participations_treatments.id IS 'Primary key';
 COMMENT ON COLUMN participations_treatments.participation_id IS 'The participation linked to this event. The participation type should be "InterestedParty"';
 COMMENT ON COLUMN participations_treatments.stop_treatment_date IS NULL;
 COMMENT ON COLUMN participations_treatments.treatment IS 'Text description of the treatment';
 COMMENT ON COLUMN participations_treatments.treatment_date IS NULL;
 COMMENT ON COLUMN participations_treatments.treatment_given_yn_id IS NULL;
 COMMENT ON COLUMN participations_treatments.treatment_id IS NULL; -- TODO Unused?
 COMMENT ON COLUMN participations_treatments.updated_at IS NULL;

 COMMENT ON TABLE people IS 'Records for each person in the database';
 COMMENT ON COLUMN people.age_type_id IS NULL; -- TODO: Unused?
 COMMENT ON COLUMN people.approximate_age_no_birthday IS NULL; -- TODO
 COMMENT ON COLUMN people.birth_date IS NULL;
 COMMENT ON COLUMN people.birth_gender_id IS NULL; 
 COMMENT ON COLUMN people.created_at IS NULL;
 COMMENT ON COLUMN people.date_of_death IS NULL;
 COMMENT ON COLUMN people.entity_id IS 'The entity record for this person';
 COMMENT ON COLUMN people.ethnicity_id IS NULL;
 COMMENT ON COLUMN people.first_name IS NULL;
 COMMENT ON COLUMN people.food_handler_id IS NULL;
 COMMENT ON COLUMN people.id IS 'Primary key';
 COMMENT ON COLUMN people.last_name IS NULL;
 COMMENT ON COLUMN people.live IS NULL;
 COMMENT ON COLUMN people.middle_name IS NULL;
 COMMENT ON COLUMN people.next_ver IS NULL; -- TODO: Unused?
 COMMENT ON COLUMN people.person_type IS 'Can be "clinician" or null';
 COMMENT ON COLUMN people.previous_ver IS NULL; -- TODO
 COMMENT ON COLUMN people.primary_language_id IS NULL;
 COMMENT ON COLUMN people.updated_at IS NULL;

 COMMENT ON TABLE people_races IS 'Links patients with races, allowing patients to be of multiple races';
 COMMENT ON COLUMN people_races.created_at IS NULL;
 COMMENT ON COLUMN people_races.entity_id IS 'The ID of this patient''s entity record';
 COMMENT ON COLUMN people_races.race_id IS 'The race associated with this person'; -- TODO: Create foreign key
 COMMENT ON COLUMN people_races.updated_at IS NULL;

 COMMENT ON TABLE places IS 'Contains place-specific information about place entities';
 COMMENT ON COLUMN places.created_at IS NULL;
 COMMENT ON COLUMN places.entity_id IS 'The entity record this place relates to';
 COMMENT ON COLUMN places.id IS 'Primary key';
 COMMENT ON COLUMN places.name IS NULL;
 COMMENT ON COLUMN places.short_name IS NULL;

 COMMENT ON TABLE places_types IS 'Links places with various types';
 COMMENT ON COLUMN places_types.place_id IS 'The place record linked to this record';
 COMMENT ON COLUMN places_types.type_id IS 'The place type for the linked place record'; -- TODO create foreign key with codes table (no, it's not external codes)
 COMMENT ON COLUMN places.updated_at IS NULL;

 COMMENT ON TABLE privileges IS 'The various privileges TriSano users may have';
 COMMENT ON COLUMN privileges.description IS NULL;
 COMMENT ON COLUMN privileges.id IS 'Primary key';
 COMMENT ON COLUMN privileges.priv_name IS NULL;

 COMMENT ON TABLE privileges_roles IS 'Links privileges with user roles';
 COMMENT ON COLUMN privileges_roles.created_at IS NULL;
 COMMENT ON COLUMN privileges_roles.id IS 'Primary key';
 COMMENT ON COLUMN privileges_roles.jurisdiction_id IS 'Allows privilege assignments to be jurisdiction-specific';
 COMMENT ON COLUMN privileges_roles.privilege_id IS 'The privilege that the linked role should be assigned';
 COMMENT ON COLUMN privileges_roles.role_id IS 'The role that the linked privilege should be assigned to';
 COMMENT ON COLUMN privileges_roles.updated_at IS NULL;

 COMMENT ON TABLE questions IS 'Questions from custom forms';
 COMMENT ON COLUMN questions.core_data IS NULL; -- TODO
 COMMENT ON COLUMN questions.core_data_attr IS NULL; -- TODO
 COMMENT ON COLUMN questions.created_at IS NULL;
 COMMENT ON COLUMN questions.data_type IS 'Check box, drop down, etc.';
 COMMENT ON COLUMN questions.form_element_id IS 'The form element this question is part of';
 COMMENT ON COLUMN questions.help_text IS NULL;
 COMMENT ON COLUMN questions.id IS 'Primary key';
 COMMENT ON COLUMN questions.is_required IS NULL;
 COMMENT ON COLUMN questions.question_text IS 'The text of this question';
 COMMENT ON COLUMN questions.short_name IS 'Short name for this question, used to group questions and answers together';
 COMMENT ON COLUMN questions.size IS NULL; -- TODO What units?
 COMMENT ON COLUMN questions.style IS 'Horizontal or vertical';
 COMMENT ON COLUMN questions.updated_at IS NULL;

 COMMENT ON TABLE role_memberships IS 'Links roles with users';
 COMMENT ON COLUMN role_memberships.created_at IS NULL;
 COMMENT ON COLUMN role_memberships.id IS 'Primary key';
 COMMENT ON COLUMN role_memberships.jurisdiction_id IS 'Allows role memberships to be jurisdiction-specific';
 COMMENT ON COLUMN role_memberships.role_id IS 'The role this user should be part of';
 COMMENT ON COLUMN role_memberships.updated_at IS NULL;
 COMMENT ON COLUMN role_memberships.user_id IS 'The user assigned to the linked role';

 COMMENT ON TABLE roles IS 'The roles available in the system';
 COMMENT ON COLUMN roles.description IS NULL;
 COMMENT ON COLUMN roles.id IS 'Primary key';
 COMMENT ON COLUMN roles.role_name IS NULL;

 COMMENT ON TABLE schema_migrations IS 'Internal use only; tracks the version of TriSano this database is prepared for';
 COMMENT ON COLUMN schema_migrations.version IS NULL;

 -- TODO
 COMMENT ON TABLE staged_messages IS NULL;
 COMMENT ON COLUMN staged_messages.created_at IS NULL;
 COMMENT ON COLUMN staged_messages.hl7_message IS NULL;
 COMMENT ON COLUMN staged_messages.id IS 'Primary key';
 COMMENT ON COLUMN staged_messages.message_type IS NULL;
 COMMENT ON COLUMN staged_messages.note IS NULL;
 COMMENT ON COLUMN staged_messages.state IS NULL;
 COMMENT ON COLUMN staged_messages.updated_at IS NULL;
 
 -- TODO
 COMMENT ON TABLE tasks IS NULL;
 COMMENT ON COLUMN tasks.category_id IS NULL;
 COMMENT ON COLUMN tasks.created_at IS NULL;
 COMMENT ON COLUMN tasks.due_date IS NULL;
 COMMENT ON COLUMN tasks.event_id IS NULL;
 COMMENT ON COLUMN tasks.id IS 'Primary key';
 COMMENT ON COLUMN tasks.name IS NULL;
 COMMENT ON COLUMN tasks.notes IS NULL;
 COMMENT ON COLUMN tasks.priority IS NULL;
 COMMENT ON COLUMN tasks.repeating_interval IS NULL;
 COMMENT ON COLUMN tasks.repeating_task_id IS NULL;
 COMMENT ON COLUMN tasks.status IS NULL;
 COMMENT ON COLUMN tasks.until_date IS NULL;
 COMMENT ON COLUMN tasks.updated_at IS NULL;
 COMMENT ON COLUMN tasks.user_id IS NULL;

 COMMENT ON TABLE telephones IS 'Records telephone numbers associated with entities';
 COMMENT ON COLUMN telephones.area_code IS NULL;
 COMMENT ON COLUMN telephones.country_code IS NULL;
 COMMENT ON COLUMN telephones.created_at IS NULL;
 COMMENT ON COLUMN telephones.email_address IS NULL;
 COMMENT ON COLUMN telephones.entity_id IS 'The entity associated with this telephone number';
 COMMENT ON COLUMN telephones.entity_location_type_id IS 'Home, mobile, etc.'; -- TODO make foreign key with external_codes
 COMMENT ON COLUMN telephones.extension IS NULL;
 COMMENT ON COLUMN telephones.id IS 'Primary key';
 COMMENT ON COLUMN telephones.location_id IS NULL; -- TODO What does this link with?
 COMMENT ON COLUMN telephones.phone_number IS NULL;
 COMMENT ON COLUMN telephones.updated_at IS NULL;
 
 COMMENT ON TABLE treatments IS 'Describes the type of treatments that can be provided';
 COMMENT ON COLUMN treatments.id IS 'Primary key';
 COMMENT ON COLUMN treatments.treatment_name IS NULL;
 COMMENT ON COLUMN treatments.treatment_type_id IS NULL; -- TODO: unused? For that matter, is this table used?

 COMMENT ON TABLE users IS 'Users in the system';
 COMMENT ON COLUMN users.created_at IS NULL;
 COMMENT ON COLUMN users.disable IS NULL;
 COMMENT ON COLUMN users.event_view_settings IS NULL; -- TODO
 COMMENT ON COLUMN users.first_name IS NULL;
 COMMENT ON COLUMN users.generational_qualifer IS NULL; -- TODO
 COMMENT ON COLUMN users.given_name IS NULL;
 COMMENT ON COLUMN users.id IS 'Primary key';
 COMMENT ON COLUMN users.initials IS NULL;
 COMMENT ON COLUMN users.last_name IS NULL;
 COMMENT ON COLUMN users.shortcut_settings IS NULL; -- TODO
 COMMENT ON COLUMN users.task_view_settings IS NULL; -- TODO
 COMMENT ON COLUMN users.uid IS NULL;
 COMMENT ON COLUMN users.updated_at IS NULL;
 COMMENT ON COLUMN users.user_name IS NULL;
