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
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

module Export
  module Cdc
    module CdcWriter
      def write(value, options)
        if value.nil?
          DEFAULT_LOGGER.info("CDC Export: Export using options #{options.inspect} on #{self.inspect} cancelled because the value was 'nil'")
          return
        end
        options = {
          :length => 1, 
          :starting => 0,
          :result => ''}.merge(options)

        diff = (options[:starting] + options[:length]) - options[:result].length
        options[:result] << ' ' * diff if diff > 0
        unless (current = options[:result][options[:starting], options[:length]]).strip.blank?
          DEFAULT_LOGGER.warn("CDC Export: Overwriting #{current} with #{value} using these options: #{options.inspect} on #{self.inspect}")
        end
        options[:result][options[:starting], options[:length]] = value.ljust(options[:length])[0, options[:length]] 
        options[:result]
      end

      def convert_value(value, conversion)
        if conversion
          converted_value = conversion.value_to
          case
          when conversion.conversion_type == 'date'
            begin
              date = Date.parse(value.to_s)
              converted_value = date.strftime(converted_value)
            rescue Exception => ex              
              DEFAULT_LOGGER.debug "CDC Export: Failed to convert date value '#{value}' because: #{ex.message}"
              return '9' * conversion.length_to_output
            end
          when conversion.conversion_type == 'single_line_text' && value
            length_to_output = conversion.length_to_output
            if value.strip =~ /^[\d+]{4}$/ && length_to_output == 2 # really just trying to catch years
              DEFAULT_LOGGER.debug("CDC Export: Treating a text field as a two digit year - #{conversion.inspect}")
              converted_value = value.rjust(length_to_output, ' ')[-length_to_output, length_to_output]              
            else                                   
              converted_value = value.ljust(length_to_output)[0, length_to_output].strip
            end
          end
          converted_value
        else
          DEFAULT_LOGGER.warn("CDC Export: '#{value ? value.inspect : 'nil'}' was not exported for #{self.inspect} because there was no export conversion was associated with it")
          return nil
        end
      end

    end

    module HumanEvent
      def nested_attribute_paths
        { 'disease_id' => [:disease_event, :disease_id],
          'county_id' => [:address, :county_id],
          'race_ids' => [:interested_party, :person_entity, :race_ids],
          'birth_gender_id' => [:interested_party, :person_entity, :person, :birth_gender_id],
          'birth_date' => [:interested_party, :person_entity, :person, :birth_date],
          'ethnicity_id' => [:interested_party, :person_entity, :person, :ethnicity_id]}        
      end

      def ibis_nested_attribute_paths
        { 'date_diagnosed' => [:disease_event, :date_diagnosed],
          'postal_code' => [:address, :postal_code],
          'primary_jurisdiction' => [:jurisdiction, :secondary_entity_id]}
      end

    end

    module EventRules
      include Export::Cdc::CdcWriter

      def export_core_field_configs
        forms = self.form_references.empty? ? self.get_investigation_forms : self.form_references.collect{|fr| fr.form}
        DEFAULT_LOGGER.info("CDC Export: No forms associated with this event: #{self.record_number}") if forms.empty?
        forms.collect do |form|          
          form.form_elements.find(:all, :conditions => ['type = ? and export_column_id is not null', 'CoreFieldElement'])
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
          value = safe_call_chain(*config.call_chain) || ''
        rescue Exception => ex
          DEFAULT_LOGGER.error("CDC Export: Value could not be retrieved: " + ex.message)
          return
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
                
        export_fields = %w(event_onset_date first_reported_PH_date state_case_status_id imported_from_id deleted_at)
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
          ids << column.export_conversion_values.collect {|value| value.id}
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
              :starting => export_conversion_value.export_column.start_position - 1, 
              :length => export_conversion_value.export_column.length_to_output,
              :result => result)
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

      def county_export_columns
        @county_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'COUNTY' AND export_disease_group_id IS NULL")
      end

      def sex_export_columns
        @sex_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'SEX' AND export_disease_group_id IS NULL")
      end

      def race_export_columns
        @race_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'RACE' AND export_disease_group_id IS NULL")
      end

      def ethnicity_export_columns
        @ethnicity_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'ETHNICITY' AND export_disease_group_id IS NULL")
      end

      def imported_export_columns
        @imported_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'IMPORTED' AND export_disease_group_id IS NULL")
      end

      def outbreak_export_columns
        @outbreak_export_columns ||= ExportColumn.find(:first, :conditions => "type_data = 'CORE' AND export_column_name = 'OUTBREAK' AND export_disease_group_id IS NULL")
      end

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
           state_case_status_id
           exp_imported
           exp_outbreak
           future
           disease_specific_records
          )
      end
      
      def to_cdc
        DEFAULT_LOGGER.debug("to_cdc on #{self.inspect}")
        cdc_export_fields.map { |field| send field }.join
      end

      def future
        ' ' * 5
      end

      def age_at_onset
        self['age_at_onset'].to_s.rjust(3, '0')
      end
      
      # This is a cheat. Sometime we should go back and fix the view.
      def state_case_status_id
        return '9' unless status_code = self['state_case_status_id']
        external_code = ExternalCode.find(status_code)
        case_status_export_column = ExportColumn.find_by_export_column_name("CASESTATUS")
        
        cdc_code = ExportConversionValue.find(:first, :conditions => 
                     ["export_column_id=? and value_from=?", 
                      case_status_export_column.id, external_code.the_code])
        cdc_code.value_to
      end

      def exp_rectype
        'M'
      end
      
      def exp_update
        ' '
      end

      def exp_state
        '49'
      end

      def exp_year
        self.MMWR_year.to_s[2..3]
      end

      def exp_caseid
        self.record_number[4..9]
      end
      
      def exp_site
        'S01'
      end

      def exp_week
        self.MMWR_week.to_s.rjust(2, '0')
      end
           
      def exp_event
        safe_call_chain(:disease_event, :disease, :cdc_code) || '99999'
      end

      def exp_count
        '00001'
      end

      def exp_county
        county = safe_call_chain(:address, :county, :the_code)
        if county
          county_export_columns.export_conversion_values.find_by_value_from(county).value_to
        else
          '999'
        end
      end

      def exp_birthdate
        exp_patient = self.interested_party.person_entity.person 
        if exp_patient.birth_date
          exp_patient.birth_date.strftime("%Y%m%d")
        else
          '99999999'
        end
      end

      def exp_agetype
        if self.age_type
          self.age_type.the_code
        else
          '9'
        end
      end

      def exp_sex 
        sex = self.interested_party.person_entity.person.birth_gender
        if sex
          sex_export_columns.export_conversion_values.find_by_value_from(sex.the_code).value_to
        else
          '9'
        end
      end

      def exp_race
        race = nil
        races = self.interested_party.person_entity.races
        unless races.empty?
          race = races.first.the_code
        end

        if race
          race_export_columns.export_conversion_values.find_by_value_from(race).value_to
        else
          '9'
        end
      end

      def exp_ethnicity
        ethnicity = self.interested_party.person_entity.person.ethnicity
        if ethnicity
          ethnicity_export_columns.export_conversion_values.find_by_value_from(ethnicity.the_code).value_to
        else
          '9'
        end
      end

      def exp_eventdate
        event_date = safe_call_chain(:disease_event, :disease_onset_date)
        event_date = safe_call_chain(:disease_event, :date_diagnosed) unless event_date 
        event_date = safe_call_chain(:definitive_lab_result, :lab_test_date) unless event_date 
        event_date = self.first_reported_PH_date unless event_date 
        if event_date
          event_date.strftime("%y%m%d")
        else
          '999999'
        end
      end

      def exp_datetype
        date_type = '1' if safe_call_chain(:disease_event, :disease_onset_date)
        date_type = '2' if safe_call_chain(:disease_event, :date_diagnosed) unless date_type 
        date_type = '3' if safe_call_chain(:definitive_lab_result, :lab_test_date) unless date_type 
        date_type = '5' if self.first_reported_PH_date unless date_type 
        date_type || '9'
      end

      def exp_imported
        imported = self.imported_from
        if imported
          imported_export_columns.export_conversion_values.find_by_value_from(imported.the_code).value_to
        else
          '9'
        end
      end

      def exp_outbreak
        outbreak = self.outbreak_associated
        if outbreak_associated
          outbreak_export_columns.export_conversion_values.find_by_value_from(outbreak_associated.the_code).value_to
        else
          '9'
        end
      end

      def disease_specific_records
        result = ''
        # Debt: Ultimately, passing in self here can go.  It's a legacy of the SQL view that was returning hashses
        # instead of Event objects. Leaving it in for now for simplicity's sake
        event_answer_conversions(self, result)
        core_field_conversions(self, result)
        (result[60...result.length] || '').rstrip  
      end      

      # Debt:  This is no longer needed.  It's also a vestige of the SQL view.  Keeping it in for now, in case I'm
      # surprised by the real world and something like this will fix it
      # def method_missing(method, *args)
      #   if self.has_key? method.to_s
      #     self.class.send(:define_method, method, lambda {self[method.to_s]})
      #     send(method, args)
      #   else
      #     super
      #   end
      # end

      private

      def event_answer_conversions(event, result)
        if event.disease_event && event.disease_event.disease
          conversion_value_ids = event.disease_event.disease.export_conversion_value_ids
          disease_filter = {:conditions => ['text_answer is not null AND export_conversion_value_id in (?)', conversion_value_ids]}
        end
        options = (disease_filter || {}).merge(:order => 'id DESC')
        answers = event.answers.export_answers(:all, options)
        DEFAULT_LOGGER.info("CDC export: No exported answers for event #{event.record_number}") if answers.empty?
        answers.each {|answer| answer.write_export_conversion_to(result)}
      end

      def core_field_conversions(event, result)
        event.export_core_field_configs.each do |config|
          event.write_conversion_for(config, :to => result)
        end
        DEFAULT_LOGGER.info("CDC Export: No additinal Core fields export for event #{event.record_number}") if event.export_core_field_configs.empty?
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

      def exp_event
        self['cdc_code']
      end
    end
  end
end

Answer.send(:include, Export::Cdc::AnswerRules)
Disease.send(:include, Export::Cdc::DiseaseRules)
