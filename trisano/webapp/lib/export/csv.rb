# Copyright (C) 2007, 2008, 2009 TheCollaborative Software Foundation
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
      full_export(events, options)      
    end

    private

    def Csv.full_export(events, options)
      # Formbuilder answers are only displayed if there is only one row to output or the user chose a specific
      # disease in the event search form, which sets the show_answers option.
      options[:show_answers] = events.size == 1 ? true : false unless options[:show_answers]
      options[:export_options] ||= []
      options[:disease] = disease_for_single_event(events.first) if ((events.size == 1) && (options[:disease].nil?))

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
      
      LineExporter.events_csv(events, options, exportable_questions)
    end

    def Csv.disease_for_single_event(event)
      begin
        Disease.find(event.disease_id) unless event.disease_id.blank?
      rescue
        nil
      end
    end

    class LineExporter
      class << self
        def events_csv(events, options, exportable_questions)
          exporter = new(events, options, exportable_questions)
          exporter.to_csv
        end
      end
      
      attr_reader :events, :options, :exportable_questions, :output
      private     :events, :options, :exportable_questions, :output

      def initialize(events, options, exportable_questions)
        @events = events
        @options = options
        @exportable_questions = exportable_questions
      end

      def to_csv
        @output = ""
        event_type = nil
        events.each do |event|
          unless event.deleted_at
            # Check to see if we're moving from one event type to another so as to spit out new headers
            event_break = (event_type == event.class.name) ? false : true
            event_type  = event.class.name
            output_header(event) if event_break
            output_body(event)
          end
        end
        output
      end

      def exporting_labs?
        export_options.include? "labs"
      end

      def exporting_treatments?
        export_options.include? "treatments"
      end

      def exporting_places?
        export_options.include? "places"
      end

      def exporting_contacts?
        export_options.include? "contacts"
      end
      
      def exporting_using_short_names?
        export_options.try(:include?, 'use_short_names')
      end

      def showing_answers?
        options[:show_answers]
      end

      private

      def export_options
        options[:export_options]
      end
      
      def output_header(event)
        csv_header  = event_headers(event)
        csv_header += lab_headers if exporting_labs?
        csv_header += treatment_headers if exporting_treatments?
        if event.is_a? MorbidityEvent
          csv_header += event_headers(PlaceEvent) if exporting_places?
          csv_header += event_headers(ContactEvent) if exporting_contacts?
        end
        csv_out(csv_header)
      end

      def event_headers(event)
        event_data(event).map { |event_datum| event_datum.first }
      end

      def lab_headers
        lab_data.map { |lab_datum| lab_datum.first }
      end

      def treatment_headers
        treatment_data.map { |treatment_datum| treatment_datum.first }
      end

      # A root-level event is either a morbidity or a contact, not a place
      def output_body(event)
        # A contact's only contact is the original patient
        num_contacts    = exporting_contacts? ? event.contact_child_events.active(true).size : 0
        #contacts don't have places
        num_places      = event.is_a?(MorbidityEvent) && exporting_places? ? event.place_child_events.active(true).size : 0
        num_lab_results = exporting_labs? ? event.lab_results.size : 0
        num_treatments  = exporting_treatments? ? event.interested_party.treatments.size : 0
        loop_ctr = [num_contacts, num_places, num_lab_results, num_treatments, 1].max

        # This silly ol' loop is 'cause the user wants the first line to consist of the first of everything: patient, labs, treatments, contacts, places.
        # The next line is to consist of the next of everything.  And so on until the largest repeating item is exhaused.  There's probably a better way.
        loop_event = event
        loop_ctr.times do |ctr| 
          csv_row = event_values(loop_event).map { |value| value.to_s.gsub(/,/,' ') }

          # Blank out the main event for successive rows, but not the ID
          loop_event = event.class.new
          loop_event.id = event.id

          if exporting_labs?
            if ctr < num_lab_results
              lab_result = event.lab_results[ctr]
            else
              lab_result = LabResult.new
            end
            csv_row += lab_values(lab_result).map { |value| value.to_s.gsub(/,/,' ') }
          end

          if exporting_treatments?
            if ctr < num_treatments
              treatment = event.interested_party.treatments[ctr]
            else
              treatment = ParticipationsTreatment.new
            end
            csv_row += treatment_values(treatment).map { |value| value.to_s.gsub(/,/,' ') }
          end

          if event.is_a? MorbidityEvent
            if exporting_places?
              if ctr < num_places
                place_event = event.place_child_events.active[ctr]
              else
                place_event = PlaceEvent.new
              end
              csv_row += event_values(place_event).map { |value| value.to_s.gsub(/,/,' ') }
            end

            if exporting_contacts?
              if ctr < num_contacts
                contact_event = event.contact_child_events.active[ctr]
              else
                contact_event = ContactEvent.new
              end
              csv_row += event_values(contact_event).map { |value| value.to_s.gsub(/,/,' ') }
            end
          end
          
          csv_out(csv_row)
        end
      end

      def event_values(event)
        if (event.is_a?(HumanEvent) && event.interested_party) || (event.is_a?(PlaceEvent) && event.interested_place)
          event_data(event).collect do |event_datum| 
            begin
              event.instance_eval(event_datum.last) 
            rescue Exception => ex
              raise ex.message + event_datum.last
            end
          end
        else
          # A little optimization.  No sense in evaling all the attributes if the event is empty due to being blanked out for following rows.
          ed = event_data(event).collect { nil }
          ed[0] = event.id
          ed
        end
      end

      def lab_values(lab_result)
        lab_data.collect do |lab_datum| 
          begin
            lab_result.instance_eval(lab_datum.last)
          rescue Exception => ex
            raise ex.message + lab_datum.last
          end
        end
      end
      
      def treatment_values(treatment)
        treatment_data.collect do |treatment_datum| 
          begin
            treatment.instance_eval(treatment_datum.last)
          rescue Exception => ex
            raise ex.message + treatment_datum.last
          end
        end
      end

      def event_data(event_or_class)
        clazz = event_or_class.is_a?(Class) ? event_or_class : event_or_class.class
        meth = "#{clazz.to_s.underscore}_fields"
        event_data = CsvField.send(meth).map do |csv_field|
          [csv_field.send(short_or_long_name), script_for(csv_field)]
        end        
        if showing_answers? and event_or_class.respond_to?(:answers)
          event_data += event_answers(event_or_class)
        end
        event_data
      end
  
      def event_answers(event)
        answers = []
        exportable_questions[event.class.name.underscore.to_sym].each do |question|
          answer = event.answers.detect { |answer| answer.short_name == question.short_name }
          text_answer = answer.nil? ? "" : answer.text_answer
          escaped_answer = text_answer.blank? ? "" : text_answer.gsub(/'/, "\\\\'")
          column_name = exporting_using_short_names? ? question.short_name : "disease_specific_#{question.short_name}"
          answers << [column_name, "'#{escaped_answer}'"]
        end
        answers
      end

      def lab_data
        CsvField.lab_fields.map do |csv_field| 
          [csv_field.send(short_or_long_name), script_for(csv_field)]
        end
      end

      def treatment_data
        CsvField.treatment_fields.map do |csv_field|      
          [csv_field.send(short_or_long_name), script_for(csv_field)]
        end
      end

      def short_or_long_name
        exporting_using_short_names? ? :short_name : :long_name
      end

      def script_for(csv_field)
        if options[csv_field.long_name] == 'use_code'
          csv_field.use_code || csv_field.use_description
        else
          csv_field.use_description
        end
      end

      def csv_out(data)
        CSV::Writer.generate(output) do |writer|
          writer << data
        end
      end

    end
  end
end
