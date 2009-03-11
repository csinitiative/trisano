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
      num_treatments  = options[:export_options].include?("treatments") ? event.interested_party.treatments.size : 0
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
            treatment = event.interested_party.treatments[ctr]
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
      if (event.is_a?(HumanEvent) && event.interested_party) || (event.is_a?(PlaceEvent) && event.interested_place)
        event_data(event, options, exportable_questions).collect do |event_datum| 
          begin
            event.instance_eval(event_datum.last) 
          rescue Exception => ex
            raise ex.message + event_datum.last
          end
        end
      else
        # A little optimization.  No sense in evaling all the attributes if the event is empty due to being blanked out for following rows.
        ed = event_data(event, options, exportable_questions).collect { nil }
        ed[0] = event.id
        ed
      end
    end

    def Csv.lab_values(lab_result)
      lab_data.collect do |lab_datum| 
        begin
          lab_result.instance_eval(lab_datum.last)
        rescue Exception => ex
          raise ex.message + lab_datum.last
        end
      end
    end

    def Csv.treatment_values(treatment)
      treatment_data.collect do |treatment_datum| 
        begin
          treatment.instance_eval(treatment_datum.last)
        rescue Exception => ex
          raise ex.message + treatment_datum.last
        end
      end
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
        event_data << ["place_name", "interested_place.place_entity.place.name"]
        event_data << ["place_type", "interested_place.place_entity.place.place_type.try(:code_description)"]
        event_data << ["place_date_of_exposure", "participations_place.try(:date_of_exposure)"]
      else
        event_data << ["#{event_type}_event_id", "id"]
        event_data << ["#{event_type}_record_number", "record_number"]
        event_data << ["#{event_type}_last_name", "interested_party.person_entity.person.last_name"]
        event_data << ["#{event_type}_first_name", "interested_party.person_entity.person.first_name"]
        event_data << ["#{event_type}_middle_name", "interested_party.person_entity.person.middle_name"]
      end

      event_data << ["#{event_type}_address_street_number", "address.try(:street_number)"]
      event_data << ["#{event_type}_address_street_name", "address.try(:street_name)"]
      event_data << ["#{event_type}_address_unit_number", "address.try(:unit_number)"]
      event_data << ["#{event_type}_address_city", "address.try(:city)"]
      event_data << ["#{event_type}_address_state", "address.try(:state).try(:code_description)"]
      event_data << ["#{event_type}_address_county", "address.try(:county).try(:code_description)"]
      event_data << ["#{event_type}_address_postal_code", "address.try(:postal_code)"]
      
      unless event.is_a?(PlaceEvent)
        event_data << ["#{event_type}_birth_date", "interested_party.person_entity.person.birth_date"]
        event_data << ["#{event_type}_approximate_age_no_birthdate", "interested_party.person_entity.person.approximate_age_no_birthday"]
        event_data << ["#{event_type}_age_at_onset_in_years", "age_info.in_years"]
      end

      if event.is_a?(PlaceEvent)
        event_data << ["place_phone_area_code", "interested_place.place_entity.telephones.last.try(:area_code)"]
        event_data << ["place_phone_phone_number", "interested_place.place_entity.telephones.last.try(:phone_number)"]
        event_data << ["place_phone_extension", "interested_place.place_entity.telephones.last.try(:extension)"]
      else
        event_data << ["#{event_type}_phone_area_code", "interested_party.person_entity.telephones.last.try(:area_code)"]
        event_data << ["#{event_type}_phone_phone_number", "interested_party.person_entity.telephones.last.try(:phone_number)"]
        event_data << ["#{event_type}_phone_extension", "interested_party.person_entity.telephones.last.try(:extension)"]
      end

      unless event.is_a?(PlaceEvent)
        event_data << ["#{event_type}_birth_gender", "interested_party.person_entity.person.try(:birth_gender).try(:code_description)"]
        event_data << ["#{event_type}_ethnicity", "interested_party.person_entity.person.try(:ethnicity).try(:code_description)"]
        
        # Cheating
        num_races = ExternalCode.count(:conditions => "code_name = 'race'")
        cnt = 0
        unless (interested_party = event.interested_party).nil?
          interested_party.person_entity.races.each do |race|
            cnt += 1
            event_data << ["#{event_type}_race_#{cnt}", "'#{race.code_description}'"]
          end
        end
        (num_races - cnt).times { |race_cnt| event_data << ["#{event_type}_race_#{cnt + race_cnt + 1}", ""] }

        event_data << ["#{event_type}_language", "interested_party.person_entity.person.try(:primary_language).try(:code_description)"]

        if event.is_a?(ContactEvent)
          event_data << ["contact_disposition", "participations_contact.try(:disposition).try(:code_description)"]
          event_data << ["contact_type", "participations_contact.try(:contact_type).try(:code_description)"]
        end

        # Clinical
        event_data << ["#{event_type}_disease", "disease_event.try(:disease).try(:disease_name)"]
        event_data << ["#{event_type}_disease_onset_date", "disease_event.try(:disease_onset_date)"]
        event_data << ["#{event_type}_date_diagnosed", "disease_event.try(:date_diagnosed)"]
        event_data << ["#{event_type}_diagnostic_facility", "diagnostic_facilities.first.try(:place_entity).try(:place).try(:name)"]

        event_data << ["#{event_type}_hospitalized", "disease_event.try(:hospitalized).try(:code_description)"]
        event_data << ["#{event_type}_hospitalization_facility", "hospitalization_facilities.first.try(:secondary_entity).try(:place).try(:name)"]
        event_data << ["#{event_type}_hospital_admission_date", "hospitalization_facilities.first.try(:hospitals_participation).try(:admission_date)"]
        event_data << ["#{event_type}_hospital_discharge_date", "hospitalization_facilities.first.try(:hospitals_participation).try(:discharge_date)"]
        event_data << ["#{event_type}_hospital_medical_record_no", "hospitalization_facilities.first.try(:hospitals_participation).try(:medical_record_number)"]

        event_data << ["#{event_type}_died", "disease_event.try(:died).try(:code_description)"]
        event_data << ["#{event_type}_date_of_death", "interested_party.person_entity.person.date_of_death"]
        event_data << ["#{event_type}_pregnant", "interested_party.try(:risk_factor).try(:pregnant).try(:code_description)"]

        event_data << ["#{event_type}_clinician_last_name", "clinicians.first.try(:person_entity).try(:person).try(:last_name)"]
        event_data << ["#{event_type}_clinician_first_name", "clinicians.first.try(:person_entity).try(:person).try(:first_name)"]
        event_data << ["#{event_type}_clinician_middle_name", "clinicians.first.try(:person_entity).try(:person).try(:middle_name)"]
        event_data << ["#{event_type}_clinician_phone_area_code", "clinicians.first.try(:person_entity).try(:telephones).try(:last).try(:area_code)"]
        event_data << ["#{event_type}_clinician_phone_phone_number", "clinicians.first.try(:person_entity).try(:telephones).try(:last).try(:phone_number)"]
        event_data << ["#{event_type}_clinician_phone_extension", "clinicians.first.try(:person_entity).try(:telephones).try(:last).try(:extension)"]

        # Edidemioligical
        event_data << ["#{event_type}_food_handler", "interested_party.try(:risk_factor).try(:food_handler).try(:code_description)"]
        event_data << ["#{event_type}_healthcare_worker", "interested_party.try(:risk_factor).try(:healthcare_worker).try(:code_description)"]
        event_data << ["#{event_type}_group_living", "interested_party.try(:risk_factor).try(:group_living).try(:code_description)"]
        event_data << ["#{event_type}_day_care_association", "interested_party.try(:risk_factor).try(:day_care_association).try(:code_description)"]
        event_data << ["#{event_type}_occupation", "interested_party.try(:risk_factor).try(:occupation)"]
        event_data << ["#{event_type}_risk_factors", "interested_party.risk_factor.try(:risk_factors)"]
        event_data << ["#{event_type}_risk_factors_notes", "interested_party.risk_factor.try(:risk_factors_notes)"]
        event_data << ["#{event_type}_imported_from", "imported_from.try(:code_description)"]

        if event.is_a?(MorbidityEvent)
          # Reporting
          event_data << ["patient_reporting_agency", "safe_call_chain(:reporting_agency, :secondary_entity, :place, :name)"]
          event_data << ["patient_reporter_last_name", "safe_call_chain(:reporter, :secondary_entity, :person, :last_name)"]
          event_data << ["patient_reporter_first_name", "safe_call_chain(:reporter, :secondary_entity, :person, :first_name)"]
          event_data << ["patient_reporter_phone_area_code", "safe_call_chain(:reporter, :secondary_entity, :telephones, :last, :area_code)"]
          event_data << ["patient_reporter_phone_phone_number", "safe_call_chain(:reporter, :secondary_entity, :telephones, :last, :phone_number)"]
          event_data << ["patient_reporter_phone_extension", "safe_call_chain(:reporter, :secondary_entity, :telephones, :last, :extension)"]
          event_data << ["patient_results_reported_to_clinician_date", "results_reported_to_clinician_date"]
          event_data << ["patient_first_reported_PH_date", "first_reported_PH_date"]

          # Admin and otherwise
          event_data << ["patient_event_onset_date", "event_onset_date"]
          event_data << ["patient_MMWR_week", "read_attribute('MMWR_week')"]
          event_data << ["patient_MMWR_year", "read_attribute('MMWR_year')"]

          event_data << ["patient_lhd_case_status", "lhd_case_status.try(:code_description)"]
          event_data << ["patient_state_case_status", "state_case_status.try(:code_description)"]
          event_data << ["patient_outbreak_associated", "outbreak_associated.try(:code_description)"]
          event_data << ["patient_outbreak_name", "outbreak_name"]

          event_data << ["patient_event_name", "event_name"]
          event_data << ["patient_jurisdiction_of_investigation", "primary_jurisdiction.try(:name)"]
          event_data << ["patient_jurisdiction_of_residence", "address.try(:county).try(:jurisdiction).try(:name)"]
          event_data << ["patient_event_status", "event_status"]
          event_data << ["patient_investigation_started_date", "investigation_started_date"]
          event_data << ["patient_investigation_completed_lhd_date", "investigation_completed_LHD_date"]
          event_data << ["patient_review_completed_by_state_date", "review_completed_by_state_date"]

          event_data << ["patient_investigator", "investigator.try(:best_name)"]
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
    lab_data << ["lab_interpretation", "interpretation.try(:code_description)"]
    lab_data << ["lab_specimen_source", "specimen_source.try(:code_description)"]
    lab_data << ["lab_collection_date", "collection_date"]
    lab_data << ["lab_test_date", "lab_test_date"]
    lab_data << ["lab_specimen_sent_to_uphl", "specimen_sent_to_uphl_yn.try(:code_description)"]
  end

  def Csv.treatment_data
    treatment_data = []
    treatment_data << ["treatment_record_id", "id"]
    treatment_data << ["treatment_given", "treatment_given_yn.try(:code_description)"]
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
