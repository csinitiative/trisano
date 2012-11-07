# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

      def self.netss_test_types
        @@netss_test_types = nil
        unless @@netss_test_types
          values = CommonTestType.all
          @@netss_test_types = Hash[values.map(&:id).zip(values.map(&:common_name))]
        end
        @@netss_test_types
      end

      def self.netss_specimen
        @@netss_specimen = nil
        unless @@netss_specimen
          values = ExportColumn.find_by_export_column_name("SPECIMEN SITE").export_conversion_values
          @@netss_specimen = Hash[values.map(&:value_from).zip(values.map(&:value_to))]
        end
        @@netss_specimen
      end

      def self.trisano_specimen
        {
          "AB" => netss_specimen["Not Applicable"],
          "AH" => netss_specimen["Not Applicable"],
          "BD" => netss_specimen["Blood/Serum"],
          "BS" => netss_specimen["Not Applicable"],
          "BT" => netss_specimen["Not Applicable"],
          "BW" => netss_specimen["Not Applicable"],
          "CS" => netss_specimen["Cervix"],
          "CSF"=> netss_specimen["Cerebrospinal fluid (CSF)"],
          "CSFB" => netss_specimen["Not Applicable"],
          "EYE" => netss_specimen["Ophthalmia/Conjunctiva"],
          "GT" => netss_specimen["Not Applicable"],
          "LA" => netss_specimen["Not Applicable"],
          "LN" => netss_specimen["Lymph Node Aspirate"],
          "LS" => netss_specimen["Lesion-Genital"],
          "NA" => netss_specimen["Not Applicable"],
          "NS" => netss_specimen["Not Applicable"],
          "OT" => netss_specimen["Other"],
          "PF" => netss_specimen["Not Applicable"],
          "RS" => netss_specimen["Rectum"],
          "SK" => netss_specimen["Not Applicable"],
          "SP" => netss_specimen["Not Applicable"],
          "ST" => netss_specimen["Not Applicable"],
          "TI" => netss_specimen["Not Applicable"],
          "TS" => netss_specimen["Naso-Pharynx"],
          "TW" => netss_specimen["Not Applicable"],
          "UNK" => netss_specimen["Unknown"],
          "UR" => netss_specimen["Urine"],
          "US" => netss_specimen["Urethra"],
          "VA" => netss_specimen["Vagina"],
          "VM" => netss_specimen["Not Applicable"]
        }
      end

      def syphilis?
        disease_name.include? "Syphilis"
      end

      def export?
        self.attributes.has_key? "export"
      end

      def kansas_and_std?
        config_option(:cdc_state) == "20" and !(self.attributes["avr_group_ids"] =~ /\b#{AvrGroup.std.id}\b/).blank?
      end

      def after_find
        if self.export?
          if self.kansas_and_std?
            self.extend(Export::Cdc::StdRecord)
          else
            self.extend(Export::Cdc::Record)
          end
        end
      end
    end

    module EventRules
      include Export::Cdc::CdcWriter
      include PostgresFu

      def export_core_field_configs
        forms = pg_array(self.disease_form_ids).collect{|fi| Form.find(fi)}
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
        if export_attributes_changed?
          self.cdc_updated_at = Date.today
          self.ibis_updated_at = Date.today if self.sent_to_ibis
        end
        # IBIS export is also interested in a few more
        if ibis_attributes_changed? && sent_to_ibis
          self.ibis_updated_at = Date.today
        end
      end

      private

      def export_attributes_changed?
        return false if new_record?

        nested_attribute_paths.each do |k, call_path|
          return true if nested_attribute_changed?(k, call_path)
        end

        %w(event_onset_date
           first_reported_PH_date
           state_case_status_id
           imported_from_id
           deleted_at).each do |field|
          return true if send("#{field}_changed?")
        end
      end

      def ibis_attributes_changed?
        ibis_nested_attribute_paths.each do |k, call_path|
          return true if nested_attribute_changed?(k, call_path)
        end
        false
      end

      def nested_attribute_changed?(nested_key, call_path)
        field = call_path.slice!(-1)
        call_path << :changed
        return true if safe_call_chain(*call_path).try(:include?, field.to_s)
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

    module Record
      include PostgresFu

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
        cdc_export_fields.map {|field|
          begin
            send field
          rescue Exception => e
            raise "Failed to export event #{self.id} on field named #{field}. #{e.message}"
          end
        }.join
      end

      def future
        ' ' * 5
      end

      def age_at_onset
        self['age_at_onset'].to_s.rjust(3, '0')
      end

      # This is a cheat. Sometime we should go back and fix the view.
      def state_case_status_id
        self.state_case_status_value || '9'
      end

      def exp_rectype
        'M'
      end

      def exp_update
        ' '
      end

      def exp_state
        config_option(:cdc_state)
      end

      def exp_year
        self.MMWR_year.to_s[2..3]
      end

      def exp_caseid
        self.record_number[-6, 6]
      end

      def exp_site
        'S01'
      end

      def exp_week
        self.MMWR_week.to_s.rjust(2, '0')
      end

      def exp_event
        self.cdc_code || '99999'
      end

      def exp_count
        '00001'
      end

      def exp_county
        unless self.county_value.blank?
          self.county_value.to_s.rjust(3, '0')
        else
          '999'
        end
      end

      def exp_birthdate
        if birth_date.blank?
          '99999999'
        else
          Date.parse(birth_date).strftime("%Y%m%d")
        end
      end

      def exp_agetype
        self.age_at_onset_type || '9'
      end

      def exp_sex
        sex.blank? ? '9' : sex
      end

      def exp_race
        race_values = pg_array(races)
        race_values.first || '9'
      end

      def exp_ethnicity
        ethnicity.blank? ? '9' : ethnicity
      end

      def exp_eventdate
        event_onset_date.strftime('%y%m%d')
      end

      def exp_datetype
        date_type = '1' if disease_onset_date
        date_type = '2' if date_diagnosed unless date_type
        date_type = '3' if pg_earliest_date(lab_test_dates) unless date_type
        date_type = '5' if first_reported_PH_date unless date_type
        date_type || '9'
      end

      def exp_imported
        self.imported_from_value || '9'
      end

      def exp_outbreak
        self.outbreak_value || '9'
      end

      def disease_specific_records
        result = ''
        # Debt: Ultimately, passing in self here can go.  It's a legacy of the SQL view that was returning hashses
        # instead of Event objects. Leaving it in for now for simplicity's sake
        write_answers_to(result)
        core_field_conversions(self, result)
        (result[60...result.length] || '').rstrip
      end

      def pg_earliest_date(array)
         return if array.blank?
         pg_array(array).map {|d| Date.parse(d) }.sort.first
      end

      def pg_closest_date(event_date, array)
        return [nil, -1] if array.blank? or event_date.blank?
        array = array.map {|d| d.to_date  }
        dates = Hash[array.map {|d| (event_date.to_date - d).abs.to_i }.zip(array) ]
        closest_date = dates[dates.keys.sort.first]
        [closest_date, array.index(closest_date)]
      end

      def pg_same_or_after(event_date, array)
        return [nil, -1] if array.blank? or event_date.blank?
        array = array.map {|d| d.to_date  }
        dates = Hash[array.map {|d| (d - event_date.to_date).to_i }.zip(array) ]

        same_or_after = dates[dates.keys.select {|k| k >= 0 }.sort.first]
        [same_or_after, array.index(same_or_after)]
      end

      private
      def write_answers_to(result)
        return if text_answers.blank?
        answers      = pg_array(self.text_answers)
        converions   = pg_array(self.value_tos)
        start_pos    = pg_array(self.start_positions)
        lengths      = pg_array(self.lengths)
        data_types   = pg_array(self.data_types)

        answers.each_with_index do |answer, i|
          converted_answer = convert_answer(answer, data_types[i], converions[i], lengths[i].to_i)
          write(converted_answer, {
                  :starting => start_pos[i].to_i - 1,
                  :length   => lengths[i].to_i,
                  :result   => result})
        end
      end

      def convert_answer(answer, data_type, value_to, length)
        case
        when data_type == 'date'
          convert_date answer, "%m/%d/%y", length
        when data_type == 'single_line_text'
          convert_single_line_text answer, length
        else
          value_to
        end
      end

      def convert_date(answer, date_format, length)
        date = Date.parse(answer.to_s)
        date.strftime(date_format)
      rescue Exception => ex
        DEFAULT_LOGGER.debug "CDC Export: Failed to convert date value '#{answer}' because: #{ex.message}"
        '9' * length
      end

      def convert_single_line_text(answer, length)
        answer.gsub!(/^"(.*?)"$/,'\1')

        if answer.strip =~ /^[\d+]{4}$/ && length == 2 # really just trying to catch years
          DEFAULT_LOGGER.debug("CDC Export: Treating a text field as a two digit year - Event #{record_number}")
          answer.rjust(length, ' ')[-length, length]
        else
          answer.ljust(length)[0, length].strip
        end
      end

      def core_field_conversions(event, result)
        if event.core_field_export_count.to_i > 0
          event.export_core_field_configs.each do |config|
            event.write_conversion_for(config, :to => result)
          end
        else
          DEFAULT_LOGGER.info("CDC Export: No additinal Core fields export for event #{event.record_number}")
        end
      end

    end

    module StdRecord
      include Record

      def to_cdc
        DEFAULT_LOGGER.debug("to_cdc on #{self.inspect}")
        cdc_export_fields.inject('') { |memo, field|
          begin
            value, pos = send field
            if pos
              memo = memo.ljust(pos - 1)
              memo[pos - 1...pos - 1 + value.length] = value
            else
              memo << value
            end
            memo
          rescue Exception => e
            raise "Failed to export event #{self.id} on field named #{field}. #{e.message}"
          end
        }
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
             exp_zip
             exp_pregnant
             exp_city
             exp_pid
             exp_origin
             exp_dx_date
             exp_specsite
             exp_specsite_date
             exp_intervw
             exp_partner
             exp_amind
             exp_asian
             exp_black
             exp_nahaw
             exp_white
             exp_raceoth
             exp_raceref
             exp_raceunk
             exp_hisplat
             exp_initial_exam_date
             exp_first_reported_to_public_health_date
             exp_treatment_date
             exp_syphtest
             exp_syphtiter
             netss_version
          )
      end

      def exp_first_reported_to_public_health_date
        value = first_reported_PH_date.blank? ? "99999999" : first_reported_PH_date.strftime('%Y%m%d')
        [value, 122]
      end

      def exp_pregnant
        value = pregnant.blank? ? "9" : pregnant
        [value, 75]
      end

      def exp_zip
        value = zip.blank? ? "99999" : zip
        [value, 65]
      end

      def reference_date
        date = date_diagnosed
        date ||=  event_onset_date
        date ||=  created_at
      end

      def exp_initial_exam_date
        value = date_diagnosed.blank? ? '99999999' : date_diagnosed.to_date.strftime('%Y%m%d')
        [value, 114]
      end

      def exp_specsite
        date, index = pg_closest_date(reference_date, pg_array(lab_test_dates))
        value = HumanEvent.trisano_specimen[pg_array(specimen_values)[index]] if date and index > -1
        value ||= '  '
        [value, 85]
      end

      def exp_specsite_date
        date, index = pg_closest_date(reference_date, pg_array(lab_collection_dates))
        value = date.blank? ? '        ' : date.strftime('%y%m%d')
        [value, 87]
      end

      def exp_treatment_date
        date, index = pg_same_or_after(date_diagnosed, pg_array(treatment_dates))
        date, index = pg_same_or_after(pg_earliest_date(lab_test_dates), pg_array(treatment_dates)) if date.blank?
        value = date.blank? ? '99999999' : date.strftime('%Y%m%d')
        [value, 130]
      end

      def lab_results_array
        dates = pg_array(lab_test_dates)
        types = pg_array(lab_test_types)
        titers = pg_array(lab_result_values)
        array = []
        dates.each_with_index do |d, index|
          array << { :date => d, :test_type => types[index].to_i, :titer => titers[index] }
        end
        array
      end

      def exp_syphtest
        value = ' '
        if syphilis?
          syphtests = lab_results_array.select {|v| /\bRPR|VDRL\b/.match(HumanEvent.netss_test_types[v[:test_type]])}
          date, index = pg_closest_date(reference_date, syphtests.map {|s| s[:date] })
          value = (HumanEvent.netss_test_types[syphtests[index][:test_type]].include?("RPR") ? '1' : '2') if date
        end
        [value, 183]
      end

      def exp_syphtiter
        value = '      '
        if syphilis?
          syphtests = lab_results_array.select {|v| /\bRPR|VDRL\b/.match(HumanEvent.netss_test_types[v[:test_type]])}
          date, index = pg_closest_date(reference_date, syphtests.map {|s| s[:date] })
          value = syphtests[index][:titer].gsub("1:", "").ljust(6) if date
        end
        [value, 184]
      end

      def exp_update
        '9'
      end

      def exp_race
        '9'
      end

      def exp_ethnicity
        '9'
      end

      def future
        '99999'
      end

      def exp_city
        ['9999', 70]
      end

      def exp_pid
        ['9', 74]
      end

      def exp_origin
        ['9', 76]
      end

      def exp_dx_date
        ['99999999', 77]
      end

      def exp_intervw
        ['9', 96]
      end

      def exp_partner
        ['9', 97]
      end

      def exp_amind
        [pg_array(races).first == '1' ? 'Y' : ' ', 98]
      end

      def exp_asian
        [pg_array(races).first == '2' ? 'Y' : ' ', 99]
      end

      def exp_black
        [pg_array(races).first == '3' ? 'Y' : ' ', 100]
      end

      def exp_nahaw
        [pg_array(races).first == '2' ? 'Y' : ' ', 101]
      end

      def exp_white
        [pg_array(races).first == '5' ? 'Y' : ' ', 102]
      end

      def exp_raceoth
        [[exp_amind, exp_asian, exp_black, exp_nahaw, exp_white, exp_raceunk].map(&:first).include?('Y') ? ' ' : 'Y', 103]
      end

      def exp_raceunk
        [pg_array(races).first == '9' ? 'Y' : ' ', 105]
      end

      def exp_raceref
        [pg_array(races).empty? ? 'Y' : ' ', 104]
      end

      def exp_hisplat
        value = case ethnicity
                  when '1' :
                    'Y'
                  when '2' :
                    'N'
                  when '9' :
                    'U'
                  else
                    'R'
                end
        [value, 106]
      end

      def netss_version
        ['03', 190]
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
