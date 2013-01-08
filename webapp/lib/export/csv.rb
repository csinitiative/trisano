# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require 'csv'

module Export
  module Csv
    reloadable!

    # To follow along:  We may be asked to export a single event or multiple events.  Top level events can
    # be root level events (Morbidity, Assessment, Contact) or a mix of both (ideally sorted first by event type).
    # For root level events we need to output labs and treatments, if any, on separate lines.  Also,
    # for morbidities and assessments only we need to output any contact or place (exposure) events associated with the event.
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
      options[:show_disease_specific_fields] = events.size == 1 ? true : false unless options[:show_disease_specific_fields]
      options[:export_options] ||= []
      options[:disease] = disease_for_single_event(events.first) if ((events.size == 1) && (options[:disease].nil?))

      exportable_questions = {
        :morbidity_event => [],
        :assessment_event => [],
        :contact_event => [],
        :place_event => []
      }

      unless options[:disease].nil?
        morbidity_forms = options[:disease].live_forms("MorbidityEvent")
        morbidity_forms.each { |form| exportable_questions[:morbidity_event].concat(form.exportable_questions) }

        assessment_forms = options[:disease].live_forms("AssessmentEvent")
        assessment_forms.each { |form| exportable_questions[:assessment_event].concat(form.exportable_questions) }

        contact_forms = options[:disease].live_forms("ContactEvent")
        contact_forms.each { |form| exportable_questions[:contact_event].concat(form.exportable_questions) }

        place_forms = options[:disease].live_forms("PlaceEvent")
        place_forms.each { |form| exportable_questions[:place_event].concat(form.exportable_questions) }
      end

      LineExporter.events_csv(events, options, exportable_questions)
    end

    def Csv.disease_for_single_event(event)
      event.disease_event.try(:disease)
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
          event.reload
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

      def exporting?(component)
        export_options.include? component.to_s
      end

      def exporting_using_short_names?
        export_options.try(:include?, 'use_short_names')
      end

      def showing_answers?
        options[:show_answers]
      end

      def showing_disease_specific_fields?
        options[:show_disease_specific_fields]
      end

      private

      def export_options
        options[:export_options]
      end

      def output_header(event)
        csv_header  = event_headers(event)
        csv_header += lab_headers if exporting?(:labs)
        csv_header += treatment_headers if exporting?(:treatments)
        if event.supports_child_events?
          csv_header += event_headers(PlaceEvent) if exporting?(:places)
          csv_header += event_headers(ContactEvent) if exporting?(:contacts)
        end
        csv_out(csv_header)
      end

      def event_headers(event)
        event_data(event).map { |event_datum| event_datum.first unless event_datum.nil? }.compact
      end

      def lab_headers
        export_group_data(:lab_fields).map { |lab_datum| lab_datum.first }
      end

      def treatment_headers
        export_group_data(:treatment_fields).map { |treatment_datum| treatment_datum.first }
      end

      def output_body(event)
        # A contact is only contact is the original patient
        
        # A root-level event is either a morbidity, contact or assessment, not a place
        num_contacts    = exporting?(:contacts) ? event.child_events.root_level_events.active.size : 0
        
        #contacts don't have places
        num_places      = event.supports_child_events? && exporting?(:places) ? event.place_child_events.active(true).size : 0
        num_lab_results = exporting?(:labs) ? event.lab_results.size : 0
        num_treatments  = exporting?(:treatments) ? event.interested_party.treatments.size : 0
        num_hospitals = (!exporting?(:hospitalization_facilities) || event.hospitalization_facilities.nil?) ? 0 : event.hospitalization_facilities.size
        loop_ctr = [num_contacts, num_places, num_lab_results, num_treatments, num_hospitals, 1].max

        # This silly ol' loop is 'cause the user wants the first line to consist of the first of everything: patient, labs, treatments, contacts, places.
        # The next line is to consist of the next of everything.  And so on until the largest repeating item is exhausted.  There's probably a better way.
        loop_event = event
        loop_ctr.times do |ctr|
          csv_row = event_values(loop_event, ctr).map { |value| value.to_s.gsub(/,/,' ') }

          blank_out_remaining_rows_for(loop_event)
          
          csv_row += export_group_values(loop_event, :lab_fields, ctr).map { |value| value.to_s.gsub(/,/,' ') } if exporting?(:labs)
          csv_row += export_group_values(loop_event, :treatment_fields, ctr).map { |value| value.to_s.gsub(/,/,' ') } if exporting?(:treatments)

          if event.supports_child_events?
            if exporting?(:places)
              if ctr < num_places
                place_event = event.place_child_events.active[ctr]
              else
                place_event = PlaceEvent.new
              end
              csv_row += event_values(place_event, ctr).map { |value| value.to_s.gsub(/,/,' ') }
            end

            if exporting?(:contacts)
              if ctr < num_contacts
                contact_event = event.child_events.root_level_events.active[ctr]
              else
                contact_event = ContactEvent.new
              end
              csv_row += event_values(contact_event, ctr, :contact_event_fields).map { |value| value.to_s.gsub(/,/,' ') }
            end
          end

          csv_out(csv_row)
        end
      end

      def blank_out_remaining_rows_for(loop_event)
        def loop_event.blank_out
          true
        end
      end

      def event_values(event, count, csv_fields_meth = nil)
        if (event.is_a?(HumanEvent) && event.interested_party) || (event.is_a?(PlaceEvent) && event.interested_place)
          event_data(event, count, csv_fields_meth).collect { |event_datum|
            unless event_datum.nil?
              begin
                value = event.instance_eval(event_datum.last).to_s
                if event_datum.last == 'updated_at' || event_datum.last == 'created_at'
                  Time.parse(value).strftime('%Y-%m-%d %H:%M')
                else
                  value
                end
              rescue Exception => ex
                raise "#{ex.message}: #{event_datum.join('|')}"
              end
            end
            
          }.compact
        else
          # A little optimization.  No sense in evaling all the attributes if the event is empty due to being blanked out for following rows.
          ed = event_data(event).collect { nil }
          ed[0] = event.id
          ed
        end
      end

      def export_group_values(event, fields, count)
        export_group_data(fields, count).collect do |lab_datum|
          begin
            event.instance_eval(lab_datum.last)
          rescue Exception => ex
            raise "#{ex.message}: #{lab_datum.join('|')}"
          end
        end
      end

      def event_data(event_or_class, count=nil, csv_fields_meth = nil)
        blank_out = (!event_or_class.is_a?(Class) && event_or_class.respond_to?(:blank_out)) ? true : false

        clazz = event_or_class.is_a?(Class) ? event_or_class : event_or_class.class
        meth = csv_fields_meth || "#{clazz.to_s.underscore}_fields"
        event_data = CsvField.send(meth).map do |csv_field|
          [csv_field.send(short_or_long_name), script_for(csv_field, count, blank_out)] if render_event_field?(event_or_class, csv_field)
        end
        if showing_answers? and event_or_class.respond_to?(:answers)
          event_data += event_answers(event_or_class)
        end
        event_data
      end

      def event_answers(event)
        answers = []

        #Export historical states
        event.event_type_transitions.each do |event_type_transition|
          exportable_questions[event_type_transition.was.underscore.to_sym].each do |question|
            answer = event.answers.detect { |answer| answer.short_name == question.short_name }
            text_answer = answer.nil? ? "" : answer.text_answer
            escaped_answer = text_answer.blank? ? "" : text_answer.gsub(/'/, "\\\\'")
            column_name = exporting_using_short_names? ? question.short_name : "disease_specific_#{question.short_name}"
            answers << [column_name, "'#{escaped_answer}'"]
          end
        end

        # Handle current state
        exportable_questions[event.class.name.underscore.to_sym].each do |question|
          answer = event.answers.detect { |answer| answer.short_name == question.short_name }
          text_answer = answer.nil? ? "" : answer.text_answer
          escaped_answer = text_answer.blank? ? "" : text_answer.gsub(/'/, "\\\\'")
          column_name = exporting_using_short_names? ? question.short_name : "disease_specific_#{question.short_name}"
          answers << [column_name, "'#{escaped_answer}'"]
        end
        answers
      end

      def export_group_data(fields, count=nil)
        CsvField.send(fields.to_sym).map do |csv_field|
          [csv_field.send(short_or_long_name), script_for(csv_field, count)]
        end
      end

      def short_or_long_name
        exporting_using_short_names? ? :short_name : :long_name
      end

      def script_for(csv_field, count=nil, blank_out=false)
        script = script_from_field(csv_field, options[csv_field.long_name])
        
        if csv_field.collection.blank?
          blank_out_value?(csv_field, count, blank_out) ? "" : script
        else
          "#{csv_field.collection}[#{count}].#{script}"
        end
      end

      def csv_out(data)
        CSV::Writer.generate(output) do |writer|
          writer << data
        end
      end

      def script_from_field(csv_field, long_name_option)
        if long_name_option == 'use_code'
          csv_field.use_code || csv_field.use_description
        else
          csv_field.use_description
        end
      end

      # For events, values need to be blanked out for all rows except for the first
      # for that particular event. These blanked-out rows contain only values in columns
      # related to multiples.
      #
      # Returns true if the value should be blanked out.
      def blank_out_value?(csv_field, counter, blank_out)
        (blank_out && csv_field.use_description != "id" && !counter.nil? && (counter > 0))
      end

      def render_event_field?(event_or_class, csv_field)
        (
          (csv_field.disease_specific == false && non_collection_or_collection_in_options?(csv_field)) ||
            (csv_field.disease_specific == true &&
              showing_disease_specific_fields? &&
              !event_or_class.is_a?(Class) &&
              !csv_field.core_field.nil? &&
              csv_field.core_field.rendered_on_event?(event_or_class) &&
              non_collection_or_collection_in_options?(csv_field)
          )
        )
      end

      def non_collection_or_collection_in_options?(csv_field)
        if csv_field.collection.blank?
          return true
        else
          @options[:export_options].include?(csv_field.collection)
        end
      end

    end
  end
end
