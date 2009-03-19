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
      csv_header += lab_headers(options) if options[:export_options].include? "labs"
      csv_header += treatment_headers(options) if options[:export_options].include? "treatments"
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

    def Csv.lab_headers(options)
      lab_data(options).map { |lab_datum| lab_datum.first }
    end

    def Csv.treatment_headers(options)
      treatment_data(options).map { |treatment_datum| treatment_datum.first }
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
      meth = "#{event.class.to_s.underscore}_fields"
      event_data = CsvField.send(meth).map do |csv_field|
        [csv_field.send(column_name(options)), csv_field.evaluation]
      end
      if options[:show_answers]
        event_data = event_data + (event_answers(event, exportable_questions, options) + event_data.slice!(-2, 2))
      end
      event_data
    end
  end
  
  def Csv.event_answers(event, exportable_questions, options)
    answers = []
    exportable_questions[event.class.name.underscore.to_sym].each do |question|
      answer = event.answers.detect { |answer| answer.short_name == question.short_name }
      text_answer = answer.nil? ? "" : answer.text_answer
      escaped_answer = text_answer.blank? ? "" : text_answer.gsub(/'/, "\\\\'")
      column_name = options[:export_options].include?('use_short_names') ? question.short_name : "disease_specific_#{question.short_name}"
      answers << [column_name, "'#{escaped_answer}'"]
    end
    answers
  end

  def Csv.lab_data(options = {})
    CsvField.lab_fields.map do |csv_field| 
      [csv_field.send(column_name(options)), csv_field.evaluation]
    end
  end

  def Csv.treatment_data(options = {})
    CsvField.treatment_fields.map do |csv_field|
      [csv_field.send(column_name(options)), csv_field.evaluation]
    end
  end

  def Csv.disease_for_single_event(event)
    begin
      Disease.find(event.disease_id) unless event.disease_id.blank?
    rescue
      nil
    end
  end

  def Csv.column_name(options)
    options[:export_options].try(:include?, 'use_short_names') ? :short_name : :long_name
  end
end
