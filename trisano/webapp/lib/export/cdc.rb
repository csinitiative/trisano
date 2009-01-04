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
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

module Export
  module Cdc
    module CdcWriter
      def write(value, options)
        return if value.nil?
        options = {
          :length => 1, 
          :starting => 0,
          :result => ''}.merge(options)
        diff = (options[:starting] + options[:length]) - options[:result].length
        options[:result] << ' ' * diff if diff > 0
        options[:result][options[:starting], options[:length]] = value
        options[:result]
      end

      def convert_value(value, conversion)        
        if conversion
          converted_value = conversion.value_to
          case
          when conversion.conversion_type == 'date' && value            
            converted_value = Date.parse(value.to_s).strftime("%m/%d/%y")
          when conversion.conversion_type == 'single_line_text' && value
            length_to_output = conversion.export_column.length_to_output
            converted_value = value.rjust(length_to_output, ' ')[-length_to_output, length_to_output]
          end
          converted_value
        end
      end

    end

    module HumanEvent
      def nested_attribute_paths
        { 'disease_id' => [:disease, :disease_id],
          'county_id' => [:active_patient, :primary_entity, :address, :county_id],
          'race_ids' => [:active_patient, :primary_entity, :race_ids],
          'birth_gender_id' => [:active_patient, :primary_entity, :person, :birth_gender_id],
          'birth_date' => [:active_patient, :primary_entity, :person, :birth_date],
          'ethnicity_id' => [:active_patient, :primary_entity, :person, :ethnicity_id]}        
      end

      def ibis_nested_attribute_paths
        { 'date_diagnosed' => [:disease, :date_diagnosed],
          'postal_code' => [:active_patient, :primary_entity, :address, :postal_code],
          'primary_jurisdiction' => [:active_jurisdiction, :secondary_entity_id]}
      end

    end

    module EventRules
      include Export::Cdc::CdcWriter

      def export_core_field_configs
        self.form_references.collect do |form_ref|          
          form_ref.form.form_elements.find(:all, 
                                           :conditions => ['type = ? and export_column_id is not null', 'CoreFieldElement'])
        end.flatten
      end

      def write_conversion_for(config, options)
        write(value_converted_using(config),
              :starting => config.export_column.start_position - 1,
              :length   => config.export_column.length_to_output,
              :result   => options[:to] || '')
      end

      def value_converted_using(config)
        begin
          value = safe_call_chain(*config.call_chain)
        rescue Exception => ex
          logger.error("CDC export value could not be retrieved: " + ex.message)
          return ''
        end
        value = value.the_code if value.respond_to? :the_code
        case config.export_column.data_type
        when "date", "single_line_text"
          conversion = config.export_column.export_conversion_values.first
        else
          conversion = config.export_column.export_conversion_values.find_by_value_from(value)
        end
        convert_value(value, conversion)
      end

      def check_export_updates
        # IBIS export is interested in all of the same fields as CDC export
        if export_attributes_changed?(old_attributes)
          self.cdc_updated_at = Date.today if self.sent_to_cdc
          self.ibis_updated_at = Date.today if self.sent_to_ibis
        end
        # IBIS export is also interested in a few more
        if ibis_attributes_changed?(old_attributes) && sent_to_ibis
          self.ibis_updated_at = Date.today
        end
      end
      
      private
      
      def export_attributes_changed?(old_attributes)
        return false if new_record?
        return false unless old_attributes                
        
        nested_attribute_paths.each do |k, call_path|
          return true if nested_attribute_changed?(k, call_path)
        end
                
        export_fields = %w(event_onset_date first_reported_PH_date udoh_case_status_id imported_from_id deleted_at)
        old_attributes.select {|k, v| export_fields.include?(k)}.reject do |field, value|
          self.attributes[field] == value
        end.size > 0
      end

      def ibis_attributes_changed?(old_attributes)
        ibis_nested_attribute_paths.each do |k, call_path|
          return true if nested_attribute_changed?(k, call_path)
        end
        false
      end

      def nested_attribute_changed?(nested_key, call_path)
        nested_attributes[nested_key] != safe_call_chain(*call_path) if nested_attributes
      end

      def nested_attribute_paths
        {}
      end
      
      def ibis_nested_attribute_paths
        {}
      end
    end

    module DiseaseRules

      def export_conversion_value_ids
        ids = []
        self.export_columns.each do |column|
          ids <<  column.export_conversion_values.collect {|value| value.id}
        end
        ids.flatten
      end

    end

    module AnswerRules
      include Export::Cdc::CdcWriter

      def Answer.export_answers(*args)
        args = [:all] if args.empty?
        with_scope(:find => {:conditions => ['export_conversion_value_id is not null']}) do
          find(*args)
        end
      end

      # modifies result string based on export conversion
      # rules. Result is lengthened if needed. Returns the value that
      # was inserted.
      def write_export_conversion_to(result)
        write(convert_value(self.text_answer, export_conversion_value), 
              :starting => start_position, 
              :length => length_to_output,
              :result => result)
      end
    
      private

      # Returns the start position, adjusted for zero based indexes.
      def start_position
        pos = safe_call_chain(:export_conversion_value, :export_column, :start_position)
        pos - 1 if pos
      end

      def length_to_output
        safe_call_chain(:export_conversion_value, :export_column, :length_to_output)
      end

    end

    module FormElementExt
      def call_chain
        if core_path
          path = core_path.scan(/\[([^\[\]]*)\]/).collect{|group| group[0].gsub(/_id$/, '')}
        end
      end
    end
   
    module Record

      def cdc_export_fields
        %w(exp_rectype
           exp_update
           exp_state
           exp_year
           exp_caseid
           exp_site
           exp_week
           exp_event
           exp_count
           exp_county
           exp_birthdate
           age_at_onset
           exp_agetype
           exp_sex 
           exp_race
           exp_ethnicity
           exp_eventdate
           exp_datetype
           udoh_case_status_id
           exp_imported
           exp_outbreak
           future
           disease_specific_records
          )
      end
      
      def to_cdc
        cdc_export_fields.map { |field| send field }.join
      end

      def future
        ' ' * 5
      end

      def age_at_onset
        self['age_at_onset'].to_s.rjust(3, '0')
      end
      
      # This is a cheat. Sometime we should go back and fix the view.
      def udoh_case_status_id
        return '9' unless status_code = self['udoh_case_status_id']
        external_code = ExternalCode.find(status_code)
        case_status_export_column = ExportColumn.find_by_export_column_name("CASESTATUS")
        
        cdc_code = ExportConversionValue.find(:first, :conditions => 
                     ["export_column_id=? and value_from=?", 
                      case_status_export_column.id, external_code.the_code])
        cdc_code.value_to
      end

      def disease_specific_records
        result = ''
        event = Event.find(event_id)
        event_answer_conversions(event, result)
        core_field_conversions(event, result)
        (result[60...result.length] || '').rstrip  
      end      

      def method_missing(method, *args)
        if self.has_key? method.to_s
          self.class.send(:define_method, method, lambda {self[method.to_s]})
          send(method, args)
        else
          super
        end
      end

      private

      def event_answer_conversions(event, result)
        if event.disease && event.disease.disease
          conversion_value_ids = event.disease.disease.export_conversion_value_ids
          disease_filter = {:conditions => ['text_answer is not null AND export_conversion_value_id in (?)', conversion_value_ids]}
        end
        options = (disease_filter || {}).merge(:order => 'id DESC')
        answers = event.answers.export_answers(:all, options)
        answers.each {|answer| answer.write_export_conversion_to(result)}
      end

      def core_field_conversions(event, result)
        event.export_core_field_configs.each do |config|
          event.write_conversion_for(config, :to => result)
        end
      end

    end

    module DeleteRecord
      include Record

      def cdc_export_fields
        %w(exp_rectype
           exp_update
           exp_state
           exp_year
           exp_caseid
           exp_site
           exp_week)
      end
        

      def exp_rectype
        'D'
      end
    end

    module VerificationRecord
      include Record

      def cdc_export_fields
        %w(exp_rectype
           exp_state
           exp_event
           count
           exp_year)
      end

      def exp_rectype
        'V'
      end

      def event_id
        nil
      end

      def count
        self['count'].rjust(5, '0')
      end
    end
  end
end

Answer.send(:include, Export::Cdc::AnswerRules)
Disease.send(:include, Export::Cdc::DiseaseRules)
