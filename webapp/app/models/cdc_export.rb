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
class CdcExport < ActiveRecord::Base

  class << self
    # since cdc reports won't span years, we'll assume the end_mmwr year is correct
    def weekly_cdc_export(start_mmwr, end_mmwr)
      raise ArgumentError unless start_mmwr.is_a?(Mmwr) && end_mmwr.is_a?(Mmwr)
      where = []
      where << ERB.new(<<-END_WHERE_CLAUSE).result(binding)
        (
          <% (start_mmwr..end_mmwr).each_with_index do |mmwr, index| %>
            <%= " OR " unless index == 0 %>
            ("MMWR_week"=<%= mmwr.mmwr_week %> AND "MMWR_year"=<%= mmwr.mmwr_year %>)
          <% end %>
          OR
          (
            cdc_updated_at BETWEEN '#{start_mmwr.mmwr_week_range.start_date}' AND '#{end_mmwr.mmwr_week_range.end_date}'
            AND
            ("MMWR_year"=#{end_mmwr.mmwr_year} OR "MMWR_year"=#{end_mmwr.mmwr_year - 1})
          )
        )
      END_WHERE_CLAUSE
      # The following issues 133 separate selects to generate the where clause component.  What's it doing?
      where << Disease.disease_status_where_clause
      where << "deleted_at IS NULL"

      events = get_cdc_events(where.compact.join(' AND '))
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def annual_cdc_export(mmwr_year)
      events = Event.find_by_sql(<<-SQL)
      SELECT
         e.id,
         e.state_case_status_id, 
         de.disease_onset_date,
         de.date_diagnosed,
         di.cdc_code,
         lab_results.lab_test_dates,
         e."first_reported_PH_date",
         e."MMWR_year",
         e."MMWR_week",
         e.record_number,
         p.birth_date,
         sex_conversions.value_to as sex,
         praces.races,
         ethnic_conversions.value_to as ethnicity,
         case_status_conversions.value_to as state_case_status_value,
         county_conversions.value_to as county_value,
         imported_from_conversions.value_to as imported_from_value,
         outbreak_conversions.value_to as outbreak_value,
         disease_answers.text_answers,
         disease_answers.value_tos,
         disease_answers.start_positions,
         disease_answers.lengths,
         disease_answers.data_types,
         form_references_counter.core_field_export_count
        FROM events e
        JOIN disease_events de ON e.id = event_id
        INNER JOIN diseases di ON de.disease_id = di.id
        JOIN participations ip ON (ip.event_id = e.id AND ip.type='InterestedParty')
        JOIN people p ON p.entity_id = ip.primary_entity_id 
        JOIN 
        (
          SELECT d.cdc_code, c.disease_id, c.external_code_id FROM diseases_external_codes c
           JOIN diseases d on c.disease_id = d.id
          WHERE d.cdc_code is not null
           AND active=true
        ) a ON (a.disease_id = de.disease_id AND e.state_case_status_id = a.external_code_id)
        LEFT JOIN external_codes sex_codes ON p.birth_gender_id = sex_codes.id        
        LEFT JOIN
        (
          SELECT z.value_from, z.value_to FROM export_columns sex_columns
          JOIN export_conversion_values z ON sex_columns.id = z.export_column_id
          WHERE sex_columns.export_column_name='SEX' 
            AND sex_columns.type_data='CORE'
            AND export_disease_group_id IS NULL
        ) sex_conversions ON sex_codes.the_code = sex_conversions.value_from
        LEFT JOIN external_codes state_case_status ON e.state_case_status_id = state_case_status.id
        LEFT JOIN
        (
          SELECT value_from, value_to FROM export_columns case_status_columns
          JOIN export_conversion_values case_status_conv ON case_status_columns.id = case_status_conv.export_column_id
          WHERE case_status_columns.export_column_name='CASESTATUS'
            AND case_status_columns.type_data='CORE'
            AND export_disease_group_id IS NULL
        ) case_status_conversions ON state_case_status.the_code = case_status_conversions.value_from
        LEFT JOIN addresses ON e.id = addresses.event_id
        LEFT JOIN external_codes county_codes ON addresses.county_id = county_codes.id
        LEFT JOIN 
        (
          SELECT value_from, value_to FROM export_columns county_columns
          JOIN export_conversion_values county_conv ON county_columns.id = county_conv.export_column_id
          WHERE county_columns.export_column_name='COUNTY'
            AND county_columns.type_data='CORE'
            AND export_disease_group_id IS NULL          
        ) county_conversions ON county_codes.the_code = county_conversions.value_from
        LEFT JOIN external_codes imported_from_codes ON e.imported_from_id = imported_from_codes.id
        LEFT JOIN 
        (
          SELECT value_from, value_to FROM export_columns imported_columns
          JOIN export_conversion_values imported_conv ON imported_columns.id = imported_conv.export_column_id
          WHERE imported_columns.export_column_name='IMPORTED'
            AND imported_columns.type_data='CORE'
            AND export_disease_group_id IS NULL          
        ) imported_from_conversions ON imported_from_codes.the_code = imported_from_conversions.value_from
        LEFT JOIN external_codes outbreak_codes ON e.outbreak_associated_id = outbreak_codes.id
        LEFT JOIN 
        (
          SELECT value_from, value_to FROM export_columns outbreak_columns
          JOIN export_conversion_values outbreak_conv ON outbreak_columns.id = outbreak_conv.export_column_id
          WHERE outbreak_columns.export_column_name='OUTBREAK'
            AND outbreak_columns.type_data='CORE'
            AND export_disease_group_id IS NULL          
        ) outbreak_conversions ON outbreak_codes.the_code = outbreak_conversions.value_from
        JOIN 
        (
          SELECT pr.entity_id, ARRAY_ACCUM(race_conversions.value_to) AS races FROM people pr
          LEFT JOIN people_races ON pr.entity_id = people_races.entity_id
          LEFT JOIN external_codes race_codes ON people_races.race_id = race_codes.id
          LEFT JOIN (
            SELECT zz.value_from, zz.value_to FROM export_columns race_columns
            JOIN export_conversion_values zz ON race_columns.id = zz.export_column_id
            WHERE race_columns.export_column_name='RACE'
             AND race_columns.type_data='CORE' AND race_columns.export_disease_group_id IS NULL
          ) race_conversions ON race_codes.the_code = race_conversions.value_from
          GROUP BY pr.entity_id
        ) praces ON praces.entity_id = p.entity_id
        LEFT JOIN external_codes ethnic_codes ON p.ethnicity_id = ethnic_codes.id        
        LEFT JOIN
        (
          SELECT zzz.value_from, zzz.value_to FROM export_columns ethnic_columns
          JOIN export_conversion_values zzz ON ethnic_columns.id = zzz.export_column_id
          WHERE ethnic_columns.export_column_name='ETHNICITY' 
            AND ethnic_columns.type_data='CORE'
            AND ethnic_columns.export_disease_group_id IS NULL
        ) ethnic_conversions ON ethnic_codes.the_code = ethnic_conversions.value_from
        JOIN
        (
          SELECT x.id as event_id, ARRAY_ACCUM(lab_test_date) as lab_test_dates FROM events x
          LEFT JOIN participations labs ON (x.id = labs.event_id AND labs."type"='Lab')
          LEFT JOIN lab_results ON labs.id = lab_results.participation_id
          GROUP BY x.id
        ) lab_results ON e.id = lab_results.event_id
        LEFT JOIN
        (
          SELECT event_id, COUNT(form_elements.id) AS core_field_export_count FROM form_references
          INNER JOIN form_elements ON form_references.form_id=form_elements.form_id
          WHERE form_elements.type='CoreFieldElement'
           AND form_elements.export_column_id IS NOT NULL
          GROUP BY event_id
        ) form_references_counter ON e.id = form_references_counter.event_id
        LEFT JOIN
        (
          SELECT
           ee.id as event_id,
           ARRAY_ACCUM(disease_answers.text_answer) as text_answers, 
           ARRAY_ACCUM(disease_answers.value_to) as value_tos,
           ARRAY_ACCUM(disease_answers.start_position) as start_positions,
           ARRAY_ACCUM(disease_answers.length_to_output) as lengths,
           ARRAY_ACCUM(disease_answers.data_type) as data_types
          FROM events ee
          INNER JOIN disease_events ON ee.id = disease_events.event_id
          INNER JOIN 
          (
            SELECT 
             eee.id as event_id, 
             answers.text_answer,
             v.value_to,
             c.start_position,
             c.length_to_output,
             c.data_type,
             diseases.id as disease_id
            FROM events eee
            INNER JOIN answers ON eee.id = answers.event_id
            INNER JOIN export_conversion_values v ON answers.export_conversion_value_id = v.id
            INNER JOIN export_columns c ON v.export_column_id = c.id
            INNER JOIN diseases_export_columns dec ON c.id = dec.export_column_id
            INNER JOIN diseases ON dec.disease_id = diseases.id
          ) disease_answers ON (ee.id = disease_answers.event_id AND disease_events.disease_id = disease_answers.disease_id)
          GROUP BY ee.id
        ) disease_answers ON (e.id = disease_answers.event_id)
        WHERE deleted_at is null
         AND "MMWR_year"=#{mmwr_year}
         AND e.type='MorbidityEvent'
      SQL
      events.map!{ |event| event.extend(Export::Cdc::Record) }     
      events
    end

    def cdc_deletes(start_mmwr, end_mmwr)
      where = [ "sent_to_cdc=true AND ((deleted_at BETWEEN '#{start_mmwr.mmwr_week_range.start_date}' AND '#{end_mmwr.mmwr_week_range.end_date}')" ]
      diseases = Disease.with_no_export_status
      unless  diseases.empty?
        unless  diseases.empty?
          where << "OR (disease_id IN (#{diseases.collect(&:id).join(',')}))"
        end
        invalid_case_status = Disease.with_invalid_case_status_clause
        unless invalid_case_status.blank?
          where << "OR #{invalid_case_status}"
        end
      end      
      where << ")"
      events = get_cdc_events(where.join(' '))
      events.map!{ |event| event.extend(Export::Cdc::DeleteRecord) }
      events
    end

    def verification_records(mmwr_year, mmwr_week=nil)
      select = 'COUNT(*), events."MMWR_year", diseases.cdc_code'
      where = '"MMWR_year"=' + mmwr_year.to_s + ' AND deleted_at IS NULL'
      disease_status_clause = Disease.disease_status_where_clause
      where << " AND #{disease_status_clause}" unless disease_status_clause.blank?
      where << " AND events.\"MMWR_week\" <= #{mmwr_week}" unless mmwr_week.blank?
      group_by = 'events."MMWR_year", diseases.cdc_code'
      records = get_cdc_events(where, select, group_by)
      records.map!{|record| record.extend(Export::Cdc::VerificationRecord)}
      records
    end

    # set sent to true for all cdc records
    def reset_sent_status(cdc_records)
      event_ids = cdc_records.compact.select {|record| record.id if record.id}
      Event.update_all('sent_to_cdc=true', ['id IN (?)', event_ids])
    end

    def get_cdc_events(where_clause, select_list=nil, group_by_clause=nil)
      # Consider refining this to minimize the number of SQL calls made later by the fetch and conver calls
      options = { :joins => "INNER JOIN disease_events ON events.id = disease_events.event_id INNER JOIN diseases ON disease_events.disease_id = diseases.id",
                  :conditions => where_clause + " AND events.type = 'MorbidityEvent'"
                }
      options[:select] = select_list if select_list
      options[:group] = group_by_clause if group_by_clause

      Event.find(:all, options)
    end
  end
end
