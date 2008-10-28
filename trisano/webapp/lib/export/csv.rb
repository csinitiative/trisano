# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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
    class Event

      # Debt:  This could all be factored a little better, but it'll do for now.  I suspect the requirements
      # will change dramtically, anyway.

      # To follow along:  We may be asked to export a single event or multiple events.  Top level events can
      # be either morbidity events, contact events or a mix of both.  For morbidities and contacts we need to
      # output labs and treatments if any on separate lines.  Also, for morbidities only we need to output
      # any contact or place (exposure) events associated with the event.  If any of /these/ contacts (which 
      # may be a repeat of a top level contact) have labs or treatments, spit them out to.  But don't follow
      # a contact's contact as that will bring you back to the morbidity event, and round and round you go.

      class << self
        def export(events, &proc)
          events = [events] unless events.respond_to?(:each)
          new.full_export(events, &proc)          
        end
      end

      def treatment_data
        treatment_data = []
        
        treatment_data << ["treatment_given", "treatment_given_yn.code_description if treatment_given_yn"]
        treatment_data << ["treatment", "treatment.treatment"]  # 2nd element should be just "treatment," but that's not working for reasons unknown
        treatment_data << ["treatment_date", "treatment_date"]
      end

      def lab_data
        lab_data = []
        
        lab_data << ["test_type", "test_type"]
        lab_data << ["lab_result", "lab_result_text"]
        lab_data << ["interpretation", "interpretation"]
        lab_data << ["specimen_source", "specimen_source.code_description if specimen_source"]
        lab_data << ["collection_date", "collection_date"]
        lab_data << ["lab_test_date", "lab_test_date"]
        lab_data << ["specimen_sent_to_uphl", "specimen_sent_to_uphl_yn.code_description if specimen_sent_to_uphl_yn"]
      end

      def event_data(event)
        if event.is_a?(HumanEvent)
          patient_or_contact = event.is_a?(MorbidityEvent) ? "patient" : "contact"
        end

        event_data = []

        # Identifiers
        event_data << ["internal_id", "id"]
        event_data << ["record_number", "record_number"]

        # Demographics
        if event.is_a?(PlaceEvent)
          event_data << ["place_name", "place.primary_entity.place_temp.name"]
          event_data << ["place_type", "place.primary_entity.place_temp.place_type.code_description if place.primary_entity.place_temp.place_type"]
          event_data << ["place_date_of_exposure", "place.primary_entity.place_temp.date_of_exposure"]
        else
          event_data << ["#{patient_or_contact}_last_name", "patient.primary_entity.person.last_name"]
          event_data << ["#{patient_or_contact}_first_name", "patient.primary_entity.person.first_name"]
          event_data << ["#{patient_or_contact}_middle_name", "patient.primary_entity.person.middle_name"]
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
          event_data << ["#{patient_or_contact}_address_street_number", "patient.primary_entity.address_entities_locations.last.location.addresses.last.street_number if !patient.primary_entity.address_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_address_street_name", "patient.primary_entity.address_entities_locations.last.location.addresses.last.street_name if !patient.primary_entity.address_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_address_unit_number", "patient.primary_entity.address_entities_locations.last.location.addresses.last.unit_number if !patient.primary_entity.address_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_address_city", "patient.primary_entity.address_entities_locations.last.location.addresses.last.city if !patient.primary_entity.address_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_address_state", "patient.primary_entity.address_entities_locations.last.location.addresses.last.state.code_description if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.state"]
          event_data << ["#{patient_or_contact}_address_county", "patient.primary_entity.address_entities_locations.last.location.addresses.last.county.code_description if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.county"]
          event_data << ["#{patient_or_contact}_address_postal_code", "patient.primary_entity.address_entities_locations.last.location.addresses.last.postal_code if !patient.primary_entity.address_entities_locations.empty?"]
        end

        unless event.is_a?(PlaceEvent)
          event_data << ["#{patient_or_contact}_birth_date", "patient.primary_entity.person.birth_date"]
          event_data << ["#{patient_or_contact}_approximate_age_no_birthdate", "patient.primary_entity.person.approximate_age_no_birthday"]
          event_data << ["#{patient_or_contact}_age_at_onset", "age_info"]
        end

        if event.is_a?(PlaceEvent)
          event_data << ["place_phone_area_code", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !place.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["place_phone_phone_number", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !place.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["place_phone_extension", "place.primary_entity.telephone_entities_locations.last.location.telephones.last.extension if !place.primary_entity.telephone_entities_locations.empty?"]
        else
          event_data << ["#{patient_or_contact}_phone_area_code", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !patient.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_phone_phone_number", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !patient.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_phone_extension", "patient.primary_entity.telephone_entities_locations.last.location.telephones.last.extension if !patient.primary_entity.telephone_entities_locations.empty?"]
        end

        unless event.is_a?(PlaceEvent)
          event_data << ["#{patient_or_contact}_birth_gender", "patient.primary_entity.person.birth_gender.code_description if patient.primary_entity.person.birth_gender"]
          event_data << ["#{patient_or_contact}_ethnicity", "patient.primary_entity.person.ethnicity.code_description if patient.primary_entity.person.ethnicity"]
          
          # Cheating
          cnt = 0
          event.patient.primary_entity.races.each do |race|
            cnt += 1
            event_data << ["race_#{cnt}", "'#{race.code_description}'"]
          end
          num_races = ExternalCode.count(:conditions => "code_name = 'race'")
          (num_races - cnt).times { |race_cnt| event_data << ["race_#{cnt + race_cnt + 1}", ""] }

          event_data << ["#{patient_or_contact}_language", "patient.primary_entity.person.primary_language.code_description if patient.primary_entity.person.primary_language"]

          if event.is_a?(ContactEvent)
            event_data << ["#{patient_or_contact}_disposition", "patient.primary_entity.person.disposition.code_description if patient.primary_entity.person.disposition"]
          end

          # Clinical
          event_data << ["#{patient_or_contact}_disease", "disease.disease.disease_name if disease"]
          event_data << ["#{patient_or_contact}_disease_onset_date", "disease.disease_onset_date if disease"]
          event_data << ["#{patient_or_contact}_date_diagnosed", "disease.date_diagnosed if disease"]
          event_data << ["#{patient_or_contact}_diagnosing_health_facility", "diagnosing_health_facilities.first.secondary_entity.place_temp.name if !diagnosing_health_facilities.empty?"]

          event_data << ["#{patient_or_contact}_hospitalized", "disease.hospitalized.code_description if (disease && disease.hospitalized)"]
          event_data << ["#{patient_or_contact}_hospitalized_health_facility", "hospitalized_health_facilities.first.secondary_entity.place_temp.name if !hospitalized_health_facilities.empty?"]
          event_data << ["#{patient_or_contact}_hospital_admission_date", "hospitalized_health_facilities.first.hospitals_participation.admission_date if !hospitalized_health_facilities.empty?"]
          event_data << ["#{patient_or_contact}_hospital_discharge_date", "hospitalized_health_facilities.first.hospitals_participation.discharge_date if !hospitalized_health_facilities.empty?"]
          event_data << ["#{patient_or_contact}_hospital_medical_record_no", "hospitalized_health_facilities.first.hospitals_participation.medical_record_number if !hospitalized_health_facilities.empty? && hospitalized_health_facilities.first.hospitals_participation"]

          event_data << ["#{patient_or_contact}_died", "disease.died.code_description if disease && disease.died"]
          event_data << ["#{patient_or_contact}_date_of_death", "patient.primary_entity.person.date_of_death"]
          event_data << ["#{patient_or_contact}_pregnant", "patient.participations_risk_factor.pregnant.code_description if patient.participations_risk_factor && patient.participations_risk_factor.pregnant"]

          event_data << ["#{patient_or_contact}_clinician_last_name", "clinicians.first.secondary_entity.person.last_name if !clinicians.empty?"]
          event_data << ["#{patient_or_contact}_clinician_first_name", "clinicians.first.secondary_entity.person.first_name if !clinicians.empty?"]
          event_data << ["#{patient_or_contact}_clinician_middle_name", "clinicians.first.secondary_entity.person.middle_name if !clinicians.empty?"]
          event_data << ["#{patient_or_contact}_clinician_phone_area_code", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.area_code if !clinicians.empty? && !clinicians.first.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_clinician_phone_phone_number", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if !clinicians.empty? && !clinicians.first.primary_entity.telephone_entities_locations.empty?"]
          event_data << ["#{patient_or_contact}_clinician_phone_extension", "clinicians.first.secondary_entity.telephone_entities_locations.last.location.telephones.last.extension if !clinicians.empty? && !clinicians.first.primary_entity.telephone_entities_locations.empty?"]

          # Edidemioligical
          event_data << ["#{patient_or_contact}_food_handler", "patient.participations_risk_factor.food_handler.code_description if patient.participations_risk_factor && patient.participations_risk_factor.food_handler"]
          event_data << ["#{patient_or_contact}_healthcare_worker", "patient.participations_risk_factor.healthcare_worker.code_description if patient.participations_risk_factor && patient.participations_risk_factor.healthcare_worker"]
          event_data << ["#{patient_or_contact}_group_living", "patient.participations_risk_factor.group_living.code_description if patient.participations_risk_factor && patient.participations_risk_factor.group_living"]
          event_data << ["#{patient_or_contact}_day_care_association", "patient.participations_risk_factor.day_care_association.code_description if patient.participations_risk_factor && patient.participations_risk_factor.day_care_association"]
          event_data << ["#{patient_or_contact}_occupation", "patient.participations_risk_factor.occupation if patient.participations_risk_factor"]
          event_data << ["#{patient_or_contact}_risk_factors", "patient.participations_risk_factor.risk_factors if patient.participations_risk_factor"]
          event_data << ["#{patient_or_contact}_risk_factors_notes", "patient.participations_risk_factor.risk_factors_notes if patient.participations_risk_factor"]
          event_data << ["#{patient_or_contact}_imported_from", "imported_from.code_description if imported_from"]

          if event.is_a?(MorbidityEvent)
            # Reporting
            event_data << ["reporting_agency", "reporting_agency.secondary_entity.place_temp.name if reporting_agency"]
            event_data << ["reporter_last_name", "reporter.secondary_entity.person.last_name if reporter && reporter.secondary_entity.person"]
            event_data << ["reporter_first_name", "reporter.secondary_entity.person.first_name if reporter && reporter.secondary_entity.person"]
            event_data << ["reporter_phone_area_code", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.area_code if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
            event_data << ["reporter_phone_phone_number", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.phone_number if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
            event_data << ["reporter_phone_extension", "reporter.secondary_entity.telephone_entities_locations.last.location.telephones.last.extension if reporter && !reporter.secondary_entity.telephone_entities_locations.empty?"]
            event_data << ["results_reported_to_clinician_date", "results_reported_to_clinician_date"]
            event_data << ["first_reported_PH_date", "first_reported_PH_date"]

            # Admin and otherwise
            event_data << ["event_onset_date", "event_onset_date"]
            event_data << ["MMWR_week", "read_attribute('MMWR_week')"]
            event_data << ["MMWR_year", "read_attribute('MMWR_year')"]

            event_data << ["lhd_case_status", "lhd_case_status.code_description if lhd_case_status"]
            event_data << ["udoh_case_status", "udoh_case_status.code_description if udoh_case_status"]
            event_data << ["outbreak_associated", "outbreak_associated.code_description if outbreak_associated"]
            event_data << ["outbreak_name", "outbreak_name"]

            event_data << ["event_name", "event_name"]
            event_data << ["jurisdiction_of_investigation", "primary_jurisdiction.name"]
            event_data << ["jurisdiction_of_residence", "patient.primary_entity.address_entities_locations.last.location.addresses.last.county.jurisdiction.name if !patient.primary_entity.address_entities_locations.empty? && patient.primary_entity.address_entities_locations.last.location.addresses.last.county && patient.primary_entity.address_entities_locations.last.location.addresses.last.county.jurisdiction"]
            event_data << ["event_status", "event_status"]
            event_data << ["investigation_started_date", "investigation_started_date"]
            event_data << ["investigation_completed_lhd_date", "investigation_completed_LHD_date"]
            event_data << ["review_completed_UDOH_date", "review_completed_UDOH_date"]

            event_data << ["investigator", "investigator.best_name if investigator"]
            event_data << ["sent_to_cdc", "sent_to_cdc"]
          end
        end

        # event_data.concat(event_answers(event))
        event_data << ["event_created_date", "created_at"]
        event_data << ["event_last_updated_date", "updated_at"]
      end

      def event_answers(event)
        answers = []
        event.answers.each { |answer| answers << [answer.short_name, "'#{answer.text_answer}'"] if answer.short_name }
        answers
      end

      def event_headers(event)
        event_data(event).map { |event_datum| event_datum.first }
      end

      def event_values(event)
        event_data(event).collect { |event_datum| event.instance_eval(event_datum.last) }
      end

      def lab_headers
        lab_data.map { |lab_datum| lab_datum.first }
      end

      def lab_values(lab_result)
        lab_data.collect { |lab_datum| lab_result.instance_eval(lab_datum.last) }
      end

      def treatment_headers
        treatment_data.map { |treatment_datum| treatment_datum.first }
      end

      def treatment_values(treatment)
        treatment_data.collect { |treatment_datum| treatment.instance_eval(treatment_datum.last) }
      end

      # A complete export of all events, includes the header. The
      # optional block can be used to modify an event, right before it
      # is converted. The event returned from the block will be used
      # in the csv.
      def full_export(events, &proc)
        str = previous_event = ""
        events.each do |event|
          event = proc.call(event) if proc
          @header_out = (previous_event == event.class.to_s ? false : true)
          csv_out(str, 0) { event_headers(event) } if @header_out
          previous_event = event.class.to_s
          export_event(str, event)
        end
        str
      end

      def add_lab_results(str, event, indent)
        if event.is_a?(HumanEvent)
          unless event.labs.empty?
            indent.times { str << '"",' }
            str << "Lab Results\n"
            csv_out(str, indent) { ["lab_name"] + lab_headers }
            event.labs.each do |lab|
              lab_name = [lab.secondary_entity.place_temp.name]
              lab.lab_results.each do |lab_result|
                csv_out(str, indent) { lab_name +lab_values(lab_result).map { |value| value.to_s.gsub(/,/,' ') } } 
              end
            end
            @header_out = true
          end
        end
      end

      def add_treatments(str, event, indent)
        if event.is_a?(HumanEvent)
          unless event.patient.participations_treatments.empty?
            indent.times { str << '"",' }
            str << "Treatments\n"
            csv_out(str, indent) { treatment_headers }
            event.patient.participations_treatments.each do |treatment|
              csv_out(str, indent) { treatment_values(treatment).map { |value| value.to_s.gsub(/,/,' ') } } 
            end
            @header_out = true
          end
        end
      end

      def export_event(str, event)
        csv_out(str, 0) { event_values(event).map { |value| value.to_s.gsub(/,/,' ') } } 
        add_lab_results(str, event, 1)
        add_treatments(str, event, 1)

        # Don't follow a contact's contacts (or a place's either)
        if event.is_a?(MorbidityEvent) 
          unless event.contacts.empty?
            @header_out = true
            str << "\"\",\"Contact Events\"\n"
            event.contacts.each do |contact|
              contact_event = ContactEvent.find(contact.secondary_entity.case_id)
              csv_out(str, 1) { event_headers(contact_event) } if @header_out
              @header_out = false
              csv_out(str, 1) { event_values(contact_event).map { |value| value.to_s.gsub(/,/,' ') } } 
              add_lab_results(str, contact_event, 2)
              add_treatments(str, contact_event, 2)
            end
            @header_out = true
          end

          unless event.place_exposures.empty?
            str << "\"\",\"Place Events\"\n"
            csv_out(str, 1) { event_headers(PlaceEvent.new) }
            event.place_exposures.each do |place|
              place_event = PlaceEvent.find(place.secondary_entity.case_id)
              csv_out(str, 1) { event_values(place_event).map { |value| value.to_s.gsub(/,/,' ') } } 
            end
            @header_out = true
          end
        end
        str
      end

      def csv_out (str, indent=0)
        indent.times { str << '"",' }
        CSV::Writer.generate(str) do |writer|
          writer << yield
        end
        str
      end
    end
  end
end
