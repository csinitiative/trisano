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

module Exporters

  module Csv

    class Event
      include ApplicationHelper

      class << self
        def export(events, &proc)
          events = [events] unless events.respond_to?(:each)
          new.full_export(events, &proc)          
        end
      end
      
      # The static headers that never change when exporting an event
      def default_headers
        %w(record_number
           event_name
           record_created_date
           disease
           event_type
           imported_from
           UDOH_case_status
           outbreak_associated
           outbreak_name
           event_status
           investigation_started_date
           investigation_completed_LHD_date
           review_completed_UDOH_date
           first_reported_PH_date
           results_reported_to_clinician_date
           disease_onset_date
           date_diagnosed
           hospitalized
           died
           pregnant
           pregnancy_due_date
           laboratory_name
           specimen_source
           lab_result_text
           collection_date
           lab_test_date
           specimen_sent_to_uphl_yn
           clinician_name
           clinician_phone
           clinician_street
           clinician_unit
           clinician_city
           clinician_postal_code
           clinician_county
           clinician_state
           clinician_district
           MMWR_year
           MMWR_week
           contact_city
           contact_county
           contact_zip
           contact_age
           contact_birth_gender
           contact_ethnicity
           contact_race
           contact_primary_language
           contact_disposition)
      end

      # A complete export of all events, includes the header. The
      # optional block can be used to modify an event, right before it
      # is converted. The event returned from the block will be used
      # in the csv.
      def full_export(events, &proc)
        result = ''
        events.each do |event|
          event = proc.call(event) if proc
          result += export_event(event)
        end
        headers.join(',') + "\n" + result
      end

      # export a single event, with no header
      def export_event(event)
        str = ''
        return str unless event
        
        event.labs << Participation.new_lab_participation if event.labs.empty?
        clinician = first_clinician(event)
        contact = first_contact(event)
        CSV::Writer.generate(str) do |writer|
          event.labs.each do |lab|
            lab.lab_results << LabResult.new if lab.lab_results.empty?
            lab.lab_results.each do |lab_result|        
              fields = []
              fields << event.record_number.to_s.gsub(/,/,' ')
              fields << event.event_name.to_s.gsub(/,/, ' ')
              fields << event.event_onset_date.to_s.gsub(/,/,' ')
              fields << ((event.disease.nil? || event.disease.disease.nil?) ? nil : event.disease.disease.disease_name.to_s.gsub(/,/,' '))
              fields << event.type.to_s.gsub(/,/,' ')
              fields << l(event.imported_from).to_s.gsub(/,/,' ')
              fields << l(event.udoh_case_status).to_s.gsub(/,/,' ')
              fields << l(event.outbreak_associated).to_s.gsub(/,/,' ')
              fields << event.outbreak_name.to_s.gsub(/,/,' ')
              fields << MorbidityEvent.get_state_description(event.event_status).to_s.gsub(/,/,' ')
              fields << event.investigation_started_date.to_s.gsub(/,/,' ')
              fields << event.investigation_completed_LHD_date.to_s.gsub(/,/,' ')
              fields << event.review_completed_UDOH_date.to_s.gsub(/,/,' ')
              fields << event.first_reported_PH_date.to_s.gsub(/,/,' ')
              fields << event.results_reported_to_clinician_date.to_s.gsub(/,/,' ')
              fields << (event.disease.nil? ? nil : event.disease.disease_onset_date.to_s.gsub(/,/,' '))
              fields << (event.disease.nil? ? nil : event.disease.date_diagnosed.to_s.gsub(/,/,' '))
              fields << (event.disease.nil? ? nil : l(event.disease.hospitalized).to_s.gsub(/,/,' ')) 
              fields << (event.disease.nil? ? nil : l(event.disease.died).to_s.gsub(/,/,' '))
              fields << (event.active_patient.participations_risk_factor.nil? ? nil : l(event.active_patient.participations_risk_factor.pregnant).to_s.gsub(/,/,' '))
              fields << (event.active_patient.participations_risk_factor.nil? ? nil : event.active_patient.participations_risk_factor.pregnancy_due_date.to_s.gsub(/,/,' '))
              fields << lab_name(lab).gsub(/,/,' ')
              fields << l(lab_result.specimen_source).to_s.gsub(/,/,' ')
              fields << lab_result.lab_result_text.to_s.gsub(/,/,' ')
              fields << lab_result.collection_date.to_s.gsub(/,/,' ')
              fields << lab_result.lab_test_date.to_s.gsub(/,/,' ')
              fields << l(lab_result.specimen_sent_to_uphl_yn).to_s.gsub(/,/,' ')
              fields << clinician.full_name
              fields << (clinician.telephone ? clinician.telephone.simple_format : nil)
              fill_clinician_address(fields, clinician)
              fields << event.MMWR_year.to_s.gsub(/,/,' ')
              fields << event.MMWR_week.to_s.gsub(/,/,' ')
              fill_contact_info(fields, contact)
              fill_form_answers(fields, event)
              writer << fields
            end
          end
        end
        str
      end

      def headers
        @headers ||= default_headers
      end

      private
      
      #Debt: I think this should be done from a method on Participation
      #(Law of Demeter), but that probably begins the discussion of single
      #table inheritance.
      def lab_name(lab_participation)
        entity = lab_participation.secondary_entity
        return '' if entity.nil?
        current_place = entity.current_place
        return '' if current_place.nil?
        current_place.name || ''
      end

      # TODO: STI
      def first_clinician(event)
        participation = event.clinicians.first
        if participation
          result = participation.secondary_entity.person
        end
        result || OpenStruct.new(Hash.new(''))
      end

      # TODO: STI
      def first_contact(event)
        participation = event.contacts.first
        if participation
          person = participation.secondary_entity.person
        end
        person || OpenStruct.new(Hash.new(''))
      end

      def fill_clinician_address(fields, clinician)
        address = clinician.address || OpenStruct.new
        fields << address.number_and_street
        fields << address.unit_number
        fields << address.city
        fields << address.postal_code
        fields << address.county_name
        fields << address.state_name
        fields << address.district_name
      end

      def fill_contact_info(fields, contact)
        address = contact.address || OpenStruct.new
        fields << address.city
        fields << address.county_name
        fields << address.postal_code
        fields << contact.age
        fields << contact.birth_gender_description
        fields << contact.ethnicity_description
        fields << contact.race_description
        fields << contact.primary_language_description
        fields << contact.disposition_description
      end

      def fill_form_answers(fields, event)
        event.answers.each do |answer|
          if short_name = answer.short_name           
            headers << short_name unless idx = headers.index(short_name)
            fields[(idx || headers.length - 1)] = answer.text_answer
          end
        end
      end
      
    end
    
  end

end
