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

class ProdEeLongLatCoreFields < ActiveRecord::Migration
  def self.up
    if ENV['UPGRADE']
      CoreField.transaction do
        new_fields.each do |f|
          code_name = f.delete('code_name')
          if code_name
            cid = CodeName.find_by_code_name(code_name)
            f['code_name_id'] = cid.id if cid
          end
          execute(<<-SQL)
            INSERT INTO core_fields (created_at,
                                     updated_at,
                                     #{f.map {|k, v| k.to_s}.join(',')})
                 VALUES(NOW(),
                        NOW(),
                        #{f.map {|k, v| "'#{v}'"}.join(',')})
          SQL

          execute("UPDATE core_fields SET can_follow_up = false WHERE key = 'contact_event[interested_party][person_entity][person][age_at_onset]';")
          execute("UPDATE core_fields SET can_follow_up = false WHERE key = 'contact_event[interested_party][person_entity][person][age_at_onset]';")

          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'single_line_text' WHERE key = 'contact_event[labs][lab_results][result_value]';")
          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'single_line_text' WHERE key = 'contact_event[labs][lab_results][units]';")
          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'single_line_text' WHERE key = 'contact_event[labs][lab_results][comment]';")
          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'drop_down' WHERE key = 'contact_event[labs][lab_results][organism]';")
          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'drop_down' WHERE key = 'contact_event[labs][lab_results][test_status]';")
          execute("UPDATE core_fields SET event_type = 'contact_event', field_type = 'drop_down' WHERE key = 'contact_event[labs][lab_results][test_result]';")

          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'single_line_text' WHERE key = 'morbidity_event[labs][lab_results][result_value]';")
          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'single_line_text' WHERE key = 'morbidity_event[labs][lab_results][units]';")
          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'single_line_text' WHERE key = 'morbidity_event[labs][lab_results][comment]';")
          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'drop_down' WHERE key = 'morbidity_event[labs][lab_results][organism]';")
          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'drop_down' WHERE key = 'morbidity_event[labs][lab_results][test_status]';")
          execute("UPDATE core_fields SET event_type = 'morbidity_event', field_type = 'drop_down' WHERE key = 'morbidity_event[labs][lab_results][test_result]';")

          execute("DELETE from csv_fields WHERE id = 185;")
        end
      end
    end
  end

  def self.down
  end

  def self.new_fields
    YAML.load(<<-FIELDS)
- key: morbidity_event[parent_guardian]
  can_follow_up: true
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[address][district]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
  code_name: district
- key: morbidity_event[reporting_agency][place_entity][telephones][area_code]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[reporting_agency][place_entity][telephones][phone_number]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[reporting_agency][place_entity][telephones][extension]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[reporting_agency][place_entity][place][place_type]
  can_follow_up: false
  fb_accessible: true
  field_type: multi_select
  event_type: morbidity_event
  code_name: placetype
- key: morbidity_event[interested_party][person_entity][telephones]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[interested_party][person_entity][email_addresses]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[clinicians]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[diagnostic_facilities]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[labs]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: morbidity_event[encounters]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: morbidity_event
- key: contact_event[parent_guardian]
  can_follow_up: true
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[address][district]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[interested_party][person_entity][telephones]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[interested_party][person_entity][email_addresses]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[interested_party][person_entity][race_ids]
  can_follow_up: false
  fb_accessible: true
  field_type: multi_select
  event_type: contact_event
- key: contact_event[clinicians]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[diagnostic_facilities]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[labs]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[other_data_1]
  can_follow_up: true
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: contact_event[other_data_2]
  can_follow_up: true
  fb_accessible: true
  field_type: single_line_text
  event_type: contact_event
- key: encounter_event[participations_encounter][user_id]
  can_follow_up: true
  fb_accessible: true
  field_type: multi_select
  event_type: encounter_event
- key: encounter_event[participations_encounter][encounter_date]
  can_follow_up: true
  fb_accessible: true
  field_type: date
  event_type: encounter_event
- key: encounter_event[participations_encounter][encounter_location_type]
  can_follow_up: true
  fb_accessible: true
  field_type: multi_select
  event_type: encounter_event
- key: encounter_event[participations_encounter][description]
  can_follow_up: true
  fb_accessible: true
  field_type: multi_line_text
  event_type: encounter_event
- key: encounter_event[treatments]
  can_follow_up: false
  fb_accessible: true
  field_type: drop_down
  event_type: encounter_event
- key: encounter_event[labs]
  can_follow_up: false
  fb_accessible: true
  field_type: single_line_text
  event_type: encounter_event
    FIELDS
  end
end
