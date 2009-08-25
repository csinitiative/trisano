require 'optparse'
require 'ostruct'
require 'trisano-web-api.rb'

class TriSanoWebApiCmr < TriSanoWebApi
  def parse_args(args, options = {})
    @options = OpenStruct.new

    script_name = caller.last.split(':').first
    @opts = OptionParser.new("Usage: #{script_name} [options]", 55, ' ') do |opts|
      opts.separator ""
      opts.separator "Options:"

      if options[:show_id]
        opts.on("--id CMR_ID",
                "CMR ID (required).") do |i|
          @options.cmr_id = i
        end
      end

      opts.on("--first_name NAME",
              "Person's first name.") do |fn|
        @options.first_name = fn
      end

      opts.on("--middle_name NAME",
              "Person's middle name.") do |mn|
        @options.middle_name = mn
      end

      opts.on("--last_name NAME",
              "Person's last name.") do |ln|
        @options.last_name = ln
      end

      opts.on("--parent_guardian NAME",
              "Parent/guardian's full name.") do |pg|
        @options.parent_guardian = pg
      end

      opts.on("--birth_date DATE",
              "Person's birth date.  Most date formats work, including YYYY-MM-DD.") do |bd|
        @options.birth_date = bd
      end

      opts.on("--approx_age_no_birthday AGE",
              "Approximate age if no birthday set.") do |aanb|
        @options.approximate_age_no_birthday = aanb
      end

      opts.on("--birth_gender GENDER",
              "Birth gender.") do |bg|
        @options.birth_gender = bg
      end

      opts.on("--ethnicity ETHNICITY",
              "Ethnicity.") do |eth|
        @options.ethnicity = eth
      end

      opts.on("--race RACE",
              "Comma-delimited list of races.") do |rc|
        @options.race = rc
      end

      opts.on("--primary_language LANGUAGE",
              "Primary language.") do |pl|
        @options.primary_language = pl
      end

      opts.on("--address_street_number NUMBER",
              "Address street number.") do |asnum|
        @options.address_street_number = asnum
      end

      opts.on("--address_street_name NAME",
              "Address street name.") do |asname|
        @options.address_street_name = asname
      end

      opts.on("--address_unit_number NUMBER",
              "Address unit number.") do |aun|
        @options.address_unit_number = aun
      end

      opts.on("--address_city CITY",
              "Address city.") do |acity|
        @options.address_city = acity
      end

      opts.on("--address_state STATE",
              "Address state.") do |ast|
        @options.address_state = ast
      end

      opts.on("--address_county COUNTY",
              "Address county.") do |acounty|
        @options.address_county = acounty
      end

      opts.on("--address_postal_code CODE",
              "Address postal code.") do |apc|
        @options.address_postal_code = apc
      end

      opts.on("--telephone_location_type LOCATION",
              "Telephone location type.") do |telt|
        @options.telephone_entity_location_type = telt
      end

      opts.on("--telephone_area_code CODE",
              "Telephone area code.") do |tac|
        @options.telephone_area_code = tac
      end

      opts.on("--telephone_number NUMBER",
              "Telephone number.") do |tn|
        @options.telephone_number = tn
      end

      opts.on("--telephone_extension NUMBER",
              "Telephone extension.") do |te|
        @options.telephone_extension = te
      end

      opts.on("--telephone_delete",
              "Delete telephone.") do |tdel|
        @options.telephone_delete = true
      end

      opts.on("--email_address EMAIL",
              "Email address.") do |ea|
        @options.email_address = ea
      end

      opts.on("--email_address_delete",
              "Delete email address.") do |edel|
        @options.email_address_delete = true
      end

      opts.on("--disease NAME",
              "Disease name.") do |d|
        @options.disease = d
      end

      opts.on("--disease_onset_date DATE",
              "Disease onset date.") do |dot|
        @options.disease_onset_date = dot
      end

      opts.on("--date_diagnosed DATE",
              "Date diagnosed.") do |dg|
        @options.date_diagnosed = dg
      end

      opts.on("--hosptalized TEXT",
              "Hospitalized? Yes, No, or Unknown.") do |h|
        @options.hospitalized = h
      end

      opts.on("--health_facility NAME",
              "Health facility name.") do |hf|
        @options.health_facility = hf
      end

      opts.on("--admission_date DATE",
              "Health facility admission_date") do |ad|
        @options.admission_date = ad
      end

      opts.on("--discharge DATE",
              "Health facility discharge date.") do |dd|
        @options.discharge_date = dd
      end

      opts.on("--medical_record_number NUMBER",
              "Medical record number.") do |mrn|
        @options.medical_record_number = mrn
      end

      opts.on("--died TEXT",
              "Died? Yes, No, or Unknown.") do |d|
        @options.died = d
      end

      opts.on("--date_of_death DATE",
              "Date of death.") do |dod|
        @options.date_of_death = dod
      end

      opts.on("--pregnant TEXT",
              "Pregnant? Yes, No, or Unknown.") do |p|
        @options.pregnant = p
      end

      opts.on("--pregnancy_due_date DATE",
              "Pregnancy due date.") do |pdd|
        @options.pregnancy_due_date = pdd
      end

      opts.on("--treatment_given_yn TEXT",
              "Treatment given? Yes, No, or Unknown.") do |tg|
        @options.treatment_given_yn = tg
      end

      opts.on("--treatment NAME",
              "Treatment name.") do |t|
        @options.treatment = t
      end

      opts.on("--treatment_date DATE",
              "Treatment date.") do |td|
        @options.treatment_date = td
      end

      opts.on("--stop_treatment_date DATE",
              "Treatment stop date.") do |std|
        @options.stop_treatment_date = std
      end

      opts.on("--clinician_first_name NAME",
              "Clinician first name.") do |cfn|
        @options.clinician_first_name = cfn
      end

      opts.on("--clinician_middle_name NAME",
              "Clinician middle name.") do |cmn|
        @options.clinician_middle_name = cmn
      end

      opts.on("--clinician_last_name NAME",
              "Clinician last name") do |cln|
        @options.clinician_last_name = cln
      end

      opts.on("--clinician_telephone_location_type LOCATION",
              "Clinician telephone location type.") do |telt|
        @options.clinician_telephone_entity_location_type = telt
      end

      opts.on("--clinician_telephone_area_code CODE",
              "Clinician telephone area code.") do |tac|
        @options.clinician_telephone_area_code = tac
      end

      opts.on("--clinician_telephone_number NUMBER",
              "Clinician telephone number.") do |tn|
        @options.clinician_telephone_number = tn
      end

      opts.on("--clinician_telephone_extension NUMBER",
              "Clinician telephone extension.") do |te|
        @options.clinician_telephone_extension = te
      end

      opts.on("--clinician_telephone_delete",
              "Delete clinician telephone.") do |tdel|
        @options.clinician_telephone_delete = true
      end

      opts.on("--lab_name NAME",
              "Lab name.") do |ln|
        @options.lab_name = ln
      end

      opts.on("--lab_test_type NAME",
              "Lab test type.") do |ltt|
        @options.lab_test_type = ltt
      end

      opts.on("--lab_test_result TEXT",
              "Lab test result.") do |ltr|
        @options.lab_test_result = ltr
      end
      
      opts.on("--lab_result_value TEXT",
              "Lab result value.") do |lrv|
        @options.lab_result_value = lrv
      end

      opts.on("--lab_result_units UNITS",
              "Lab result units.") do |lru|
        @options.lab_result_units = lru
      end

      opts.on("--lab_reference_range RANGE",
              "Lab reference range.") do |lrr|
        @options.lab_reference_range = lrr
      end

      opts.on("--lab_test_status STATUS",
              "Lab test status.") do |lts|
        @options.lab_test_status = lts
      end

      opts.on("--lab_speciman_source SOURCE",
              "Lab speciman source.") do |lss|
        @options.lab_speciman_source = lss
      end

      opts.on("--lab_speciman_collection_date DATE",
              "Lab speciman collection date.") do |cd|
        @options.lab_speciman_collection_date = cd
      end

      opts.on("--lab_test_date DATE",
              "Lab test date.") do |ltd|
        @options.lab_test_date = ltd
      end

      opts.on("--lab_speciman_sent_to_state TEXT",
              "Sent to state? Yes, No, or Unknown.") do |sts|
        @options.lab_speciman_sent_to_state = sts
      end

      opts.on("--lab_comment TEXT",
              "Lab comment.") do |lc|
        @options.lab_comment = lc
      end

      opts.on("--contact_first_name NAME",
              "Contact last name.") do |cfn|
        @options.contact_first_name = cfn
      end

      opts.on("--contact_middle_name NAME",
              "Contact middle name.") do |cmn|
        @options.contact_middle_name = cmn
      end

      opts.on("--contact_last_name NAME",
              "Contact last name") do |cln|
        @options.contact_last_name = cln
      end

      opts.on("--contact_disposition NAME",
              "Contact disposition.") do |cd|
        @options.contact_disposition = cd
      end

      opts.on("--contact_type TYPE",
              "Contact type.") do |ct|
        @options.contact_type = ct
      end

      opts.on("--contact_telephone_location_type LOCATION",
              "Contact telephone location type.") do |telt|
        @options.contact_telephone_entity_location_type = telt
      end

      opts.on("--contact_telephone_area_code CODE",
              "Contact telephone area code.") do |tac|
        @options.contact_telephone_area_code = tac
      end

      opts.on("--contact_telephone_number NUMBER",
              "Contact telephone number.") do |tn|
        @options.contact_telephone_number = tn
      end

      opts.on("--contact_telephone_extension NUMBER",
              "Contact telephone extension.") do |te|
        @options.contact_telephone_extension = te
      end

      opts.on("--contact_telephone_delete",
              "Delete contact telephone.") do |tdel|
        @options.contact_telephone_delete = true
      end

      opts.on("--encounter_investigator USERNAME",
              "Encounter investigator's username.") do |ei|
        @options.encounter_investigator = ei
      end

      opts.on("--encounter_date DATE",
              "Encounter date.") do |ed|
        @options.encounter_date = ed
      end

      opts.on("--encounter_location NAME",
              "Encounter location.") do |el|
        @options.encounter_location = el
      end

      opts.on("--food_handler TEXT",
              "Food handler? Yes, No, Unknown.") do |fh|
        @options.food_handler = fh
      end

      opts.on("--healthcare_work TEXT",
              "Healthcare work? Yes, No, Unknown.") do |hw|
        @options.healthcare_work = fw
      end

      opts.on("--group_living TEXT",
              "Group living? Yes, No, Unknown.") do |gl|
        @options.group_living = fh
      end

      opts.on("--day_care_association TEXT",
              "Day care association? Yes, No, Unknown.") do |dca|
        @options.day_care_association = dca
      end

      opts.on("--occupation TEXT",
              "Occupation name.") do |o|
        @options.occupation = o
      end

      opts.on("--place_date_of_exposure DATE",
              "Place date of exposure.") do |doe|
        @options.place_date_of_exposure = doe
      end 

      opts.on("--imported_from TEXT",
              "Imported from.") do |i|
        @options.imported_from = i
      end

      opts.on("--risk_factors TEXT",
              "Risk factors.") do |rf|
        @options.risk_factors = rf
      end

      opts.on("--risk_factors_notes TEXT",
              "Risk factors notes.") do |rfn|
        @options.risk_factors_notes = rfn
      end

      opts.on("--other_data_1 TEXT",
              "Other data 1.") do |od1|
        @options.other_data_1 = od1
      end

      opts.on("--other_data_2 TEXT",
              "Other data 2.") do |od2|
        @options.other_data_2 = od2
      end

      opts.on("--reporter_first_name NAME",
              "Report first name.") do |rfn|
        @options.reporter_first_name
      end

      opts.on("--reporter_last_name NAME",
              "Report last name.") do |rln|
        @options.reporter_last_name
      end

      opts.on("--reporter_first_name NAME",
              "Report first name.") do |rfn|
        @options.reporter_first_name
      end

      opts.on("--reporter_telephone_area_code CODE",
              "Reporter telephone area code.") do |tac|
        @options.reporter_telephone_area_code = tac
      end

      opts.on("--reporter_telephone_number NUMBER",
              "Reporter telephone number.") do |tn|
        @options.reporter_telephone_number = tn
      end

      opts.on("--reporter_telephone_extension NUMBER",
              "Reporter telephone extension.") do |te|
        @options.reporter_telephone_extension = te
      end

      opts.on("--results_reported_to_clinician_date DATE",
              "Results reported to clinician date.") do |cd|
        @options.results_reported_to_clinician_date = cd
      end

      opts.on("--first_reported_ph_date DATE",
              "First reported to public health date.") do |ph|
        @options.first_reported_ph_date = ph
      end

      opts.on("--note TEXT",
              "Event notes.") do |n|
        @options.note = n
      end

      opts.on("--lhd_case_status STATUS",
              "Local health department case status.") do |cs|
        @options.lhd_case_status = cs
      end

      opts.on("--state_case_status STATUS",
              "State case status.") do |cs|
        @options.state_case_status = cs
      end

      opts.on("--outbreak_associated TEXT",
              "Outbreak associated? Yes, No, Unknown.") do |oa|
        @options.outbreak_associated = oa
      end

      opts.on("--outbreak_name NAME",
              "Outbreak name.") do |on|
        @options.outbreak_name = on
      end

      opts.on("--event_name NAME",
              "Event name.") do |en|
        @options.event_name = en
      end

      opts.on("--jurisdiction_responsible_for_investigation TEXT",
              "Jurisdiction responsible for investigation.") do |j|
        @options.jurisdiction_responsible_for_investigation = j
      end

      opts.on("--investigation_started_date DATE",
              "Investigation started date.") do |isd|
        @options.investigation_started_date = isd
      end

      opts.on("--investigation_completed_lhd_date DATE",
              "Investigation completed by local health department date.") do |lcd|
        @options.investigation_completed_lhd_date = lcd
      end

      opts.on("--review_completed_by_state_date DATE",
              "Review completed by state date.") do |sd|
        @options.review_completed_by_state_date = sd
      end

      opts.on("--acuity",
              "Acuity.") do |a|
        @options.acuity = a
      end

    end

    @opts.parse!(args)
    @options
  end

  def populate_form(form)
    if !@options.first_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][first_name]'] = @options.first_name
    end
    if !@options.middle_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][middle_name]'] = @options.middle_name
    end
    if !@options.last_name.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][last_name]'] = @options.last_name
    end
    if !@options.birth_date.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_date]'] = @options.birth_date
    end
    if !@options.parent_guardian.nil?
      form['morbidity_event[parent_guardian]'] = @options.parent_guardian
    end
    if !@options.approximate_age_no_birthday.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][approximate_age_no_birthday]'] = @options.approximate_age_no_birthday
    end
    if !@options.birth_gender.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][birth_gender_id]').options.each do |s|
        if s.text == @options.birth_gender
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Birth gender not found in form' if not found
    end
    if !@options.ethnicity.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][ethnicity_id]').options.each do |s|
        if s.text == @options.ethnicity
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Ethnicity not found in form' if not found
    end
    if !@options.race.nil?
      found = 0
      races = @options.race.split(/,\s*/)
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][race_ids][]').options.each do |s|
        if races.include?(s.text)
          found += 1
          s.select
        else
          s.unselect
        end
      end
      raise 'Race not found in form' if found != races.length
    end
    if !@options.primary_language.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][primary_language_id]').options.each do |s|
        if s.text == @options.primary_language
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Primary language not found in form' if not found
    end
    if !@options.address_street_number.nil?
      form['morbidity_event[address_attributes][street_number]'] = @options.address_street_number
    end
    if !@options.address_street_name.nil?
      form['morbidity_event[address_attributes][street_name]'] = @options.address_street_name
    end
    if !@options.address_unit_number.nil?
      form['morbidity_event[address_attributes][unit_number]'] = @options.address_unit_number
    end
    if !@options.address_city.nil?
      form['morbidity_event[address_attributes][city]'] = @options.address_city
    end
    if !@options.address_state.nil?
      found = false
      form.field('morbidity_event[address_attributes][state_id]').options.each do |s|
        if s.text == @options.address_state
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Address state not found in form' if not found
    end
    if !@options.address_county.nil?
      found = false
      form.field('morbidity_event[address_attributes][county_id]').options.each do |s|
        if s.text == @options.address_county
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Address county not found in form' if not found
    end
    if !@options.address_postal_code.nil?
      form['morbidity_event[address_attributes][postal_code]'] = @options.address_postal_code
    end
    # This needs to be reworked as its own restful resource
    if !@options.telephone_entity_location_type.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]').options.each do |s|
        if s.text == @options.telephone_entity_location_type
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Telephone location type not found in form' if not found
    end
    if !@options.telephone_area_code.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]'] = @options.telephone_area_code
    end
    if !@options.telephone_number.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]'] = @options.telephone_number
    end
    if !@options.telephone_extension.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]'] = @options.telephone_extension
    end
    if !@options.telephone_delete.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][telephones_attributes][0][_delete]'] = true
    end
    if !@options.email_address.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][email_address]'] = @options.email_address
    end
    if !@options.email_address_delete.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][email_addresses_attributes][1][_delete]'] = true
    end
    if !@options.disease.nil?
      found = false
      form.field('morbidity_event[disease_event_attributes][disease_id]').options.each do |s|
        if s.text == @options.disease
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Disease not found in form' if not found
    end
    if !@options.disease_onset_date.nil?
      form['morbidity_event[disease_event_attributes][disease_onset_date]'] = @options.disease_onset_date
    end
    if !@options.date_diagnosed.nil?
      form['morbidity_event[disease_event_attributes][date_diagnosed]'] = @options.date_diagnosed
    end
    if !@options.hospitalized.nil?
      found = false
      form.field('morbidity_event[disease_event_attributes][hospitalized_id]').options.each do |s|
        if s.text == @options.hospitalized
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Hospitalized option not found in form' if not found
    end
    if !@options.health_facility.nil?
      found = false
      form.field('morbidity_event[hospitalization_facilities_attributes][0][secondary_entity_id]').options.each do |s|
        if s.text == @options.health_facility
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Health facility not found in form' if not found
    end
    if !@options.admission_date.nil?
      form['morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][admission_date]'] = @options.admission_date
    end
    if !@options.discharge_date.nil?
      form['morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][discharge_date]'] = @options.discharge_date
    end
    if !@options.medical_record_number.nil?
      form['morbidity_event[hospitalization_facilities_attributes][0][hospitals_participation_attributes][medical_record_number]'] = @options.medical_record_number
    end
    if !@options.died.nil?
      found = false
      form.field('morbidity_event[disease_event_attributes][died_id]').options.each do |s|
        if s.text == @options.died
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Died option not found in form' if not found
    end
    if !@options.date_of_death.nil?
      form['morbidity_event[interested_party_attributes][person_entity_attributes][person_attributes][date_of_death]'] = @options.date_of_death
    end
    if !@options.pregnant.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][risk_factor_attributes][pregnant_id]').options.each do |s|
        if s.text == @options.pregnant
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Pregnant option not found in form' if not found
    end
    if !@options.pregnancy_due_date.nil?
      form['morbidity_event[interested_party_attributes][risk_factor_attributes][pregnancy_due_date]'] = @options.pregnancy_due_date
    end
    if !@options.treatment_given_yn.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_given_yn_id]').options.each do |s|
        if s.text == @options.treatment_given_yn
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Treatment given option not found in form' if not found
    end
    if !@options.treatment.nil?
      form['morbidity_event[interested_party_attributes][treatments_attributes][0][treatment]'] = @options.treatment
    end
    if !@options.treatment_date.nil?
      form['morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_date]'] = @options.treatment_date
    end
    if !@options.stop_treatment_date.nil?
      form['morbidity_event[interested_party_attributes][treatments_attributes][0][stop_treatment_date]'] = @options.stop_treatment_date
    end
    if !@options.clinician_first_name.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][first_name]'] = @options.clinician_first_name
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]'] = 'clinician'
    end
    if !@options.clinician_middle_name.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][middle_name]'] = @options.clinician_middle_name
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]'] = 'clinician'
    end
    if !@options.clinician_last_name.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][first_name]'] = @options.clinician_last_name
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][person_attributes][person_type]'] = 'clinician'
    end
    if !@options.clinician_telephone_entity_location_type.nil?
      found = false
      form.field('morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][entity_location_type_id]').options.each do |s|
        if s.text == @options.clinician_telephone_entity_location_type
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Clinician telephone location type not found in form' if not found
    end
    if !@options.clinician_telephone_area_code.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][area_code]'] = @options.clinician_telephone_area_code
    end
    if !@options.clinician_telephone_number.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][phone_number]'] = @options.clinician_telephone_number
    end
    if !@options.clinician_telephone_extension.nil?
      form['morbidity_event[clinicians_attributes][1][person_entity_attributes][telephones_attributes][0][extension]'] = @options.clinician_telephone_extension
    end
    if !@options.contact_first_name.nil?
      form['morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][first_name]'] = @options.contact_first_name
    end
    if !@options.contact_last_name.nil?
      form['morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][person_attributes][last_name]'] = @options.contact_last_name
    end
    if !@options.disposition.nil?
      found = false
      form.field('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][disposition_id]').options.each do |s|
        if s.text == @options.disposition
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Disposition not found in form' if not found
    end
    if !@options.contact_type.nil?
      found = false
      form.field('morbidity_event[contact_child_events_attributes][4][participations_contact_attributes][contact_type_id]').options.each do |s|
        if s.text == @options.contact_type
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Contact type not found in form' if not found
    end
    if !@options.contact_telephone_entity_location_type.nil?
      found = false
      form.field('morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][entity_location_type_id]').options.each do |s|
        if s.text == @options.contact_telephone_entity_location_type
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Contact telephone location type not found in form' if not found
    end
    if !@options.contact_telephone_area_code.nil?
      form['morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][area_code]'] = @options.contact_telephone_area_code
    end
    if !@options.contact_telephone_number.nil?
      form['morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][phone_number]'] = @options.contact_telephone_number
    end
    if !@options.contact_telephone_extension.nil?
      form['morbidity_event[contact_child_events_attributes][4][interested_party_attributes][person_entity_attributes][telephones_attributes][0][extension]'] = @options.contact_telephone_extension
    end
    if !@options.food_handler.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][risk_factor_attributes][food_handler_id]').options.each do |s|
        if s.text == @options.food_handler
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Food handler option not found in form' if not found
    end
    if !@options.healthcare_worker.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][risk_factor_attributes][healthcare_worker_id]').options.each do |s|
        if s.text == @options.healthcare_worker
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Healthcare worker option not found in form' if not found
    end
    if !@options.group_living.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][risk_factor_attributes][group_living_id]').options.each do |s|
        if s.text == @options.group_living
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Group living option not found in form' if not found
    end
    if !@options.day_care_association.nil?
      found = false
      form.field('morbidity_event[interested_party_attributes][risk_factor_attributes][day_care_association_id]').options.each do |s|
        if s.text == @options.day_care_association
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Day care association option not found in form' if not found
    end
    if !@options.occupation.nil?
      form['morbidity_event[interested_party_attributes][risk_factor_attributes][occupation]'] = @options.occupation
    end
    if !@options.place_date_of_exposure.nil?
      form['morbidity_event[place_child_events_attributes][5][participations_place_attributes][date_of_exposure]'] = @options.place_date_of_exposure
    end
    if !@options.imported_from.nil?
      found = false
      form.field('morbidity_event[imported_from_id]').options.each do |s|
        if s.text == @options.imported_from
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Imported from option not found in form' if not found
    end
    if !@options.risk_factors.nil?
      form['morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors]'] = @options.risk_factors
    end
    if !@options.risk_facotors_notes.nil?
      form['morbidity_event[interested_party_attributes][risk_factor_attributes][risk_factors_notes]'] = @options.risk_factors_notes
    end
    if !@options.other_data_1.nil?
      form['morbidity_event[other_data_1]'] = @options.other_data_1
    end
    if !@options.other_data_2.nil?
      form['morbidity_event[other_data_2]'] = @options.other_data_2
    end
    if !@options.reporter_first_name.nil?
      form['morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][first_name]'] = @options.reporter_first_name
    end
    if !@options.reporter_last_name.nil?
      form['morbidity_event[reporter_attributes][person_entity_attributes][person_attributes][last_name]'] = @options.reporter_last_name
    end
    if !@options.reporter_telephone_area_code.nil?
      form['morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][area_code]'] = @options.reporter_telephone_area_code
    end
    if !@options.reporter_telephone_number.nil?
      form['morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][phone_number]'] = @options.reporter_telephone_number
    end
    if !@options.reporter_telephone_extension.nil?
      form['morbidity_event[reporter_attributes][person_entity_attributes][telephones_attributes][0][extension]'] = @options.reporter_telephone_extension
    end
    if !@options.results_reported_to_clinician_date.nil?
      form['morbidity_event[results_reported_to_clinician_date]'] = @options.results_reported_to_clinician_date
    end
    if !@options.first_reported_ph_date.nil?
      form['morbidity_event[first_reported_PH_date]'] = @options.first_reported_ph_date
    end
    if !@options.note.nil?
      form['morbidity_event[notes_attributes][0][note]'] = @options.note
    end
    if !@options.lhd_case_status.nil?
      found = false
      form.field('morbidity_event[lhd_case_status_id]').options.each do |s|
        if s.text == @options.lhd_case_status
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'LHD case status not found in form' if not found
    end
    if !@options.state_case_status.nil?
      found = false
      form.field('morbidity_event[state_case_status_id]').options.each do |s|
        if s.text == @options.state_case_status
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'State case status not found in form' if not found
    end
    if !@options.oubreak_associated.nil?
      found = false
      form.field('morbidity_event[outbreak_associated_id]').options.each do |s|
        if s.text == @options.outbreak_associated
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Outbreak associated option not found in form' if not found
    end
    if !@options.outbreak_name.nil?
      form['morbidity_event[outbreak_name]'] = @options.outbreak_name
    end
    if !@options.event_name.nil?
      form['morbidity_event[event_name]'] = @options.event_name
    end
    if !@options.jurisdiction_responsible_for_investigation.nil?
      found = false
      form.field('morbidity_event[jurisdiction_attributes][secondary_entity_id]').options.each do |s|
        if s.text == @options.jurisdiction_responsible_for_investigation
          found = true
          s.select
        else
          s.unselect
        end
      end
      raise 'Jurisdiction not found in form' if not found
    end
    if !@options.investigation_started_date.nil?
      form['morbidity_event[investigation_started_date]'] = @options.investigation_started_date
    end
    if !@options.investigation_completed_lhd_date.nil?
      form['morbidity_event[investigation_completed_lhd_date]'] = @options.investigation_completed_lhd_date
    end
    if !@options.review_completed_by_state_date.nil?
      form['morbidity_event[review_completed_by_state_date]'] = @options.review_completed_by_state_date
    end
    if !@options.acuity.nil?
      form['morbidity_event[acuity]'] = @options.acuity
    end

    form
  end
end
