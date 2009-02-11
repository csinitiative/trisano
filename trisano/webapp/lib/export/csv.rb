# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.# 

require 'csv'

module Export
  module Csv

    # To follow along:  We may be asked to export a single event or multiple events.  Top level events can
    # be either morbidity events, contact events or a mix of both (ideally sorted first by event type).  
    # For morbidities and contacts we need to output labs and treatments, if any, on separate lines.  Also, 
    # for morbidities only we need to output any contact or place (exposure) events associated with the event.

    def Csv.export(events, options={}, &proc)
      events = [events] unless events.respond_to?(:each)
      return if events.empty?
      raise ArgumentError unless events.first.is_a? Event
      full_export(events, options, &proc)          
    end

    private

    def Csv.full_export(events, options, &proc)
      # Formbuilder answers are only displayed if there is only one row to output or the user chose a specific
      # disease in the event search form, which sets the show_answers option.
      options[:show_answers] = events.size == 1 ? true : false unless options[:show_answers]
      options[:export_options] ||= []
      options[:disease] = disease_for_single_event(events.first) if ((events.size == 1) && (options[:disease].nil?))

      output = ""
      event_type = nil
      exportable_questions = {
        :morbidity_event => [],
        :contact_event => [],
        :place_event => []
      }

      unless options[:disease].nil?
        morbidity_forms = options[:disease].live_forms("MorbidityEvent")
        morbidity_forms.each { |form| exportable_questions[:morbidity_event].concat(form.exportable_questions) }

        contact_forms = options[:disease].live_forms("ContactEvent")
        contact_forms.each { |form| exportable_questions[:contact_event].concat(form.exportable_questions) }

        place_forms = options[:disease].live_forms("PlaceEvent")
        place_forms.each { |form| exportable_questions[:place_event].concat(form.exportable_questions) }
      end
      
      events.each do |event|
        # Give the user a chance to convert an event into some other event.  Used mainly by search.
        event = proc.call(event) if proc
        
        unless event.deleted_at
          # Check to see if we're moving from one event type to another so as to spit out new headers
          event_break = (event_type == event.class.name) ? false : true
          event_type  = event.class.name
          output_header(event, output, options, exportable_questions) if event_break
          output_body(event, output, options, exportable_questions)
        end
      end
      output
    end

    def Csv.output_header(event, output, options, exportable_questions)
      csv_header  = event_headers(event, options, exportable_questions)
      csv_header += lab_headers if options[:export_options].include? "labs"
      csv_header += treatment_headers if options[:export_options].include? "treatments"
      if event.is_a? MorbidityEvent
        csv_header += event_headers(PlaceEvent.new, options, exportable_questions) if options[:export_options].include? "places"
        csv_header += event_headers(ContactEvent.new, options, exportable_questions) if options[:export_options].include? "contacts"
      end
      csv_out(output, csv_header)
    end

    # A root-level event is either a morbidity or a contact, not a place
    def Csv.output_body(event, output, options, exportable_questions)
      # A contact's only contact is the original patient
      num_contacts    = options[:export_options].include?("contacts") ? event.contact_child_events.active(true).size : 0
      #contacts don't have places
      num_places      = event.is_a?(MorbidityEvent) && options[:export_options].include?("places") ? event.place_child_events.active(true).size : 0
      num_lab_results = options[:export_options].include?("labs") ? event.lab_results.size : 0
      num_treatments  = options[:export_options].include?("treatments") ? event.patient.participations_treatments.size : 0
      loop_ctr = [num_contacts, num_places, num_lab_results, num_treatments, 1].max

      # This silly ol' loop is 'cause the user wants the first line to consist of the first of everything: patient, labs, treatments, contacts, places.
      # The next line is to consist of the next of everything.  And so on until the largest repeating item is exhaused.  There's probably a better way.
      loop_event = event
      loop_ctr.times do |ctr| 
        csv_row   = event_values(loop_event, options, exportable_questions).map { |value| value.to_s.gsub(/,/,' ') }

        # Blank out the main event for successive rows, but not the ID
        loop_event = event.class.new
        loop_event.id = event.id

        if options[:export_options].include? "labs"
          if ctr < num_lab_results
            lab_result = event.lab_results[ctr]
          else
            lab_result = LabResult.new
          end
          csv_row += lab_values(lab_result).map { |value| value.to_s.gsub(/,/,' ') }
        end

        if options[:export_options].include? "treatments"
          if ctr < num_treatments
            treatment = event.patient.participations_treatments[ctr]
          else
            treatment = ParticipationsTreatment.new
          end
          csv_row += treatment_values(treatment).map { |value| value.to_s.gsub(/,/,' ') }
        end

        if event.is_a? MorbidityEvent
          if options[:export_options].include? "places"
            if ctr < num_places
              place_event = event.place_child_events.active[ctr]
            else
              place_event = PlaceEvent.new
            end
            csv_row += event_values(place_event, options, exportable_questions).map { |value| value.to_s.gsub(/,/,' ') }
          end

          if options[:export_options].include? "contacts"
            if ctr < num_contacts
              contact_event = event.contact_child_events.active[ctr]
            else
              contact_event = ContactEvent.new
            end
            csv_row += event_values(contact_event, options, exportable_questions).map { |value| value.to_s.gsub(/,/,' ') }
          end
        end

        csv_out(output, csv_row)
      end
    end

    def Csv.event_headers(event, options, exportable_questions)
      event_data(event, options, exportable_questions).map { |event_datum| event_datum.first }
    end

    def Csv.lab_headers
      lab_data.map { |lab_datum| lab_datum.first }
    end

    def Csv.treatment_headers
      treatment_data.map { |treatment_datum| treatment_datum.first }
    end

    def Csv.event_values(event, options, exportable_questions)
      if (event.is_a?(HumanEvent) && event.active_patient) || (event.is_a?(PlaceEvent) && event.active_place)
        event_data(event, options, exportable_questions).collect { |event_datum| event.instance_eval(event_datum.last) }
      else
        # A little optimization.  No sense in evaling all the attributes if the event is empty due to being blanked out for following rows.
        ed = event_data(event, options, exportable_questions).collect { nil }
        ed[0] = event.id
        ed
      end
    end

    def Csv.lab_values(lab_result)
      lab_data.collect { |lab_datum| lab_result.instance_eval(lab_datum.last) }
    end

    def Csv.treatment_values(treatment)
      treatment_data.collect { |treatment_datum| treatment.instance_eval(treatment_datum.last) }
    end

    def Csv.csv_out(str, data)
      CSV::Writer.generate(str) do |writer|
        writer << data
      end
    end

    def Csv.event_data(event, options, exportable_questions)
      event_type = if event.is_a?(MorbidityEvent)
        "patient"
      elsif event.is_a?(ContactEvent)
        "contact"
      else
        "place"
      end

      event_data = []

      # This data structure (an array of arrays, the nested array consisting of a header string and the code to be eval'd to retrieve the value) doesn't
      # really buy us much, _BUT_ it keeps us from misalligning headers and columns.

      # Demographics
      if event.is_a?(PlaceEvent)
        event_data << ["place_event_id", "id"]
        event_data << ["place_name", "place.primary_entity.place_temp.name"]
        event_data << ["place_type", "place.primary_entity.place_temp.place_type.code_description if place.primary_entity.place_temp.place_type"]
        event_data << ["place_date_of_exposure", "place.participations_place.date_of_exposure"]
      else
        event_data << ["#{event_type}_event_id", "id"]
        event_data << ["#{event_type}_record_number", "record_number"]
        event_data << ["#{event_type}_last_name", "patient.primary_entity.person.last_name"]
        event_data << ["#{event_type}_first_name", "patient.primary_entity.person.first_name"]
        event_data << ["#{event_type}_middle_name", "patient.primary_entity.person.middle_name"]
      end

      if event.is_a?(PlaceEvent)
        event_data << ["place_address_street_number", "place.primary_entity.address_entities_locations.last.location.addresses.last.street_number if !place.primary_entity.address_entities_locations.empty?"]
        event_data << ["place_address_street_name", "place.primary_entity.address_entities_locations.last.location.addresses.last.street_name if !place.primary_entity.address_entities_locations.empty?"]
        event_data << ["place_address_unit_number", "place.primary_entity.address_entities_locations.last.location.addresses.last.unit_number if !place.primary_entity.address_entities_locations.empty?"]
        event_data << ["place_address_city", "place.primary_entity.address_entities_locations.last.location.addresses.last.city if !place.primary_entity.address_entities_locations.empty?"]
        event_data << ["place_address_state", "place.primary_entity.address_entities_locations.last.location.addresses.last.state.code_description if !place.primary_entity.address_entities_locations.empty? && place.primary_entity.address_entities_locations.last.location.addresses.last.state"]
        event_data << ["place_address_county", "place.primary_entity.address_entities_locations.last.location.addresses.last.county.code_description if !place.primary_entity.address_entities_locations.empty? && place.primary_entity.address_entities_locations.last.location.addresses.last.county"]
        event_data << ["place_address_postal_code", "place.primary_entity.address_entities_locations.last.location.addresses.last.postal_code if !place.primary_entity.address_entities_locations.empty?"]
      else
        event_data << ["#{event_type}_address_street_number", "patient.primary_entity.address_entities_locations.last.location.addresses.last.street_number if !patient.primary_entity.address_entities_locations.empty?"]
        event_data << ["#{event_type}_address_street_name", "patient.primary_entity.address_entities_locations.last.location.addresses.last.street_name if !patient.primary_entity.address_entities_locations.empty?"]
        event_data << ["#{event_type}_address_unit_number", "patient.primary_entity.address_entities_locations.last.location.addresses.last.unit_number if !patient.primary_entity.address_entities_locations.empty?"]
        event_data << ["#{event_type}_address_city", "patient.primary_entity.address_entities_locations.last.location.addresses.last.city if !patient.primary_entity.address_entities_locations.empty?"]
        event_data << ["#{event_type}_address_state", "patient.primary_entity.address_entities_locations.last.location.addresses.last.state.code_description if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.state"]
        event_data << ["#{event_type}_address_county", "patient.primary_entity.address_entities_locations.last.location.addresses.last.county.code_description if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.county"]
        event_data << ["#{event_type}_address_postal_code", "patient.primary_entity.address_entities_locations.last.location.addresses.last.postal_code if !patient.primary_entity.address_entities_locations.empty?"]
      end

      unless event.is_a?(PlaceEvent)
        event_data << ["#{event_type}_birth_date", "patient.primary_entity.person.birth_date"]
        event_data << ["#{event_type}_approximate_age_no_birthdate", "patient.primary_entity.person.approximate_age_no_birthday"]
        event_data << ["#{event_type}_age_at_onset_in_years", "age_info.in_years"]
      end

      if event.is_a?(PlaceEvent)
        event_data << ["place_phone_area_code", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !place.primary_entity.telephone_entities_locations.empty?"]
        event_data << ["place_phone_phone_number", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !place.primary_entity.telephone_entities_locations.empty?"]
        event_data << ["place_phone_extension", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.extension if !place.primary_entity.telephone_entities_locations.empty?"]
      else
        event_data << ["#{event_type}_phone_area_code", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !patient.primary_entity.telephone_entities_locations.empty?"]
        event_data << ["#{event_type}_phone_phone_number", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !patient.primary_entity.telephone_entities_locations.empty?"]
        event_data << ["#{event_type}_phone_extension", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.extension if !patient.primary_entity.telephone_entities_locations.empty?"]
      end

      unless event.is_a?(PlaceEvent)
        event_data << ["#{event_type}_birth_gender", "patient.primary_entity.person.birth_gender.code_description if patient.primary_entity.person.birth_gender"]
        event_data << ["#{event_type}_ethnicity", "patient.primary_entity.person.ethnicity.code_description if patient.primary_entity.person.ethnicity"]
        
        # Cheating
        num_races = ExternalCode.count(:conditions => "code_name = 'race'")
        cnt = 0
        unless event.patient.nil?
          event.patient.primary_entity.races.each do |race|
            cnt += 1
            event_data << ["#{event_type}_race_#{cnt}", "'#{race.code_description}'"]
          end
        end
        (num_races - cnt).times { |race_cnt| event_data << ["#{event_type}_race_#{cnt + race_cnt + 1}", ""] }

        event_data << ["#{event_type}_language", "patient.primary_entity.person.primary_language.code_description if patient.primary_entity.person.primary_language"]

        if event.is_a?(ContactEvent)
          event_data << ["contact_disposition", "patient.participations_contact.disposition.code_description if patient.participations_contact && patient.participations_contact.disposition"]
          event_data << ["contact_type", "patient.participations_contact.contact_type.code_description if patient.participations_contact && patient.participations_contact.contact_type"]
        end

        # Clinical
        event_data << ["#{event_type}_disease", "disease.disease.disease_name if disease && disease.disease"]
        event_data << ["#{event_type}_disease_onset_date", "disease.disease_onset_date if disease"]
        event_data << ["#{event_type}_date_diagnosed", "disease.date_diagnosed if disease"]
        event_data << ["#{event_type}_diagnosing_health_facility", "diagnosing_health_facilities.first.secondary_entity.place_temp.name if !diagnosing_health_facilities.empty? && diagnosing_health_facilities.first.secondary_entity"]

        event_data << ["#{event_type}_hospitalized", "disease.hospitalized.code_description if (disease && disease.hospitalized)"]
        event_data << ["#{event_type}_hospitalized_health_facility", "hospitalized_health_facilities.first.secondary_entity.place_temp.name if !hospitalized_health_facilities.empty? && hospitalized_health_facilities.first.secondary_entity"]
        event_data << ["#{event_type}_hospital_admission_date", "hospitalized_health_facilities.first.hospitals_participation.admission_date if !hospitalized_health_facilities.empty? && hospitalized_health_facilities.first.hospitals_participation"]
        event_data << ["#{event_type}_hospital_discharge_date", "hospitalized_health_facilities.first.hospitals_participation.discharge_date if !hospitalized_health_facilities.empty? && hospitalized_health_facilities.first.hospitals_participation"]
        event_data << ["#{event_type}_hospital_medical_record_no", "hospitalized_health_facilities.first.hospitals_participation.medical_record_number if !hospitalized_health_facilities.empty? && hospitalized_health_facilities.first.hospitals_participation"]

        event_data << ["#{event_type}_died", "disease.died.code_description if disease && disease.died"]
        event_data << ["#{event_type}_date_of_death", "patient.primary_entity.person.date_of_death"]
        event_data << ["#{event_type}_pregnant", "patient.participations_risk_factor.pregnant.code_description if patient.participations_risk_factor && patient.participations_risk_factor.pregnant"]

        event_data << ["#{event_type}_clinician_last_name", "clinicians.first.secondary_entity.person.last_name if !clinicians.empty?"]
        event_data << ["#{event_type}_clinician_first_name", "clinicians.first.secondary_entity.person.first_name if !clinicians.empty?"]
        event_data << ["#{event_type}_clinician_middle_name", "clinicians.first.secondary_entity.person.middle_name if !clinicians.empty?"]
        event_data << ["#{event_type}_clinician_phone_area_code", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !clinicians.empty? && !clinicians.first.secondary_entity.telephone_entities_locations.empty?"]
        event_data << ["#{event_type}_clinician_phone_phone_number", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !clinicians.empty? && !clinicians.first.secondary_entity.telephone_entities_locations.empty?"]
        event_data << ["#{event_type}_clinician_phone_extension", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.extension if !clinicians.empty? && !clinicians.first.secondary_entity.telephone_entities_locations.empty?"]

        # Edidemioligical
        event_data << ["#{event_type}_food_handler", "patient.participations_risk_factor.food_handler.code_description if patient.participations_risk_factor && patient.participations_risk_factor.food_handler"]
        event_data << ["#{event_type}_healthcare_worker", "patient.participations_risk_factor.healthcare_worker.code_description if patient.participations_risk_factor && patient.participations_risk_factor.healthcare_worker"]
        event_data << ["#{event_type}_group_living", "patient.participations_risk_factor.group_living.code_description if patient.participations_risk_factor && patient.participations_risk_factor.group_living"]
        event_data << ["#{event_type}_day_care_association", "patient.participations_risk_factor.day_care_association.code_description if patient.participations_risk_factor && patient.participations_risk_factor.day_care_association"]
        event_data << ["#{event_type}_occupation", "patient.participations_risk_factor.occupation if patient.participations_risk_factor"]
        event_data << ["#{event_type}_risk_factors", "patient.participations_risk_factor.risk_factors if patient.participations_risk_factor"]
        event_data << ["#{event_type}_risk_factors_notes", "patient.participations_risk_factor.risk_factors_notes if patient.participations_risk_factor"]
        event_data << ["#{event_type}_imported_from", "imported_from.code_description if imported_from"]

        if event.is_a?(MorbidityEvent)
          # Reporting
          event_data << ["patient_reporting_agency", "reporting_agency.secondary_entity.place_temp.name if reporting_agency"]
          event_data << ["patient_reporter_last_name", "reporter.secondary_entity.person.last_name if reporter && reporter.secondary_entity.person"]
          event_data << ["patient_reporter_first_name", "reporter.secondary_entity.person.first_name if reporter && reporter.secondary_entity.person"]
          event_data << ["patient_reporter_phone_area_code", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.area_code if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
          event_data << ["patient_reporter_phone_phone_number", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
          event_data << ["patient_reporter_phone_extension", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.extension if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
          event_data << ["patient_results_reported_to_clinician_date", "results_reported_to_clinician_date"]
          event_data << ["patient_first_reported_PH_date", "first_reported_PH_date"]

          # Admin and otherwise
          event_data << ["patient_event_onset_date", "event_onset_date"]
          event_data << ["patient_MMWR_week", "read_attribute('MMWR_week')"]
          event_data << ["patient_MMWR_year", "read_attribute('MMWR_year')"]

          event_data << ["patient_lhd_case_status", "lhd_case_status.code_description if lhd_case_status"]
          event_data << ["patient_state_case_status", "state_case_status.code_description if state_case_status"]
          event_data << ["patient_outbreak_associated", "outbreak_associated.code_description if outbreak_associated"]
          event_data << ["patient_outbreak_name", "outbreak_name"]

          event_data << ["patient_event_name", "event_name"]
          event_data << ["patient_jurisdiction_of_investigation", "primary_jurisdiction.name if primary_jurisdiction"]
          event_data << ["patient_jurisdiction_of_residence", "patient.primary_entity.address_entities_locations.last.location.addresses.last.county.jurisdiction.name if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.county && patient.primary_entity.address_entities_locations.last.location.addresses.last.county.jurisdiction"]
          event_data << ["patient_event_status", "event_status"]
          event_data << ["patient_investigation_started_date", "investigation_started_date"]
          event_data << ["patient_investigation_completed_lhd_date", "investigation_completed_LHD_date"]
          event_data << ["patient_review_completed_by_state_date", "review_completed_by_state_date"]

          event_data << ["patient_investigator", "investigator.best_name if investigator"]
          event_data << ["patient_sent_to_cdc", "sent_to_cdc"]
          event_data << ["acuity", "acuity"]
          event_data << ["other_data_1", "other_data_1"]
          event_data << ["other_data_2", "other_data_2"]
        end
      end

      event_data.concat(event_answers(event, exportable_questions)) if options[:show_answers]
      event_data << ["#{event_type}_event_created_date", "created_at"]
      event_data << ["#{event_type}_event_last_updated_date", "updated_at"]
      event_data
    end
  end

  def Csv.event_answers(event, exportable_questions)
    answers = []
    exportable_questions[event.class.name.underscore.to_sym].each do |question|
      answer = event.answers.detect { |answer| answer.short_name == question.short_name }
      text_answer = answer.nil? ? "" : answer.text_answer
      escaped_answer = text_answer.blank? ? "" : text_answer.gsub(/'/, "\\\\'")
      answers << ["disease_specific_#{question.short_name}", "'#{escaped_answer}'"]
    end
    answers
  end

  def Csv.lab_data
    lab_data = []
    lab_data << ["lab_record_id", "id"]
    lab_data << ["lab_name", "lab_name"]
    lab_data << ["lab_test_type", "test_type"]
    lab_data << ["lab_test_detail", "test_detail"]
    lab_data << ["lab_result", "lab_result_text"]
    lab_data << ["lab_reference_range", "reference_range"]
    lab_data << ["lab_interpretation", "interpretation.code_description if interpretation"]
    lab_data << ["lab_specimen_source", "specimen_source.code_description if specimen_source"]
    lab_data << ["lab_collection_date", "collection_date"]
    lab_data << ["lab_test_date", "lab_test_date"]
    lab_data << ["lab_specimen_sent_to_uphl", "specimen_sent_to_uphl_yn.code_description if specimen_sent_to_uphl_yn"]
  end

  def Csv.treatment_data
    treatment_data = []
    treatment_data << ["treatment_record_id", "id"]
    treatment_data << ["treatment_given", "treatment_given_yn.code_description if treatment_given_yn"]
    treatment_data << ["treatment", "treatment.treatment"]  # 2nd element should be just "treatment," but that's not working for reasons unknown
    treatment_data << ["treatment_date", "treatment_date"]
  end

  def Csv.disease_for_single_event(event)
    begin
      Disease.find(event.disease_id) unless event.disease_id.blank?
    rescue
      nil
    end
  end

end
