class LabProdMigration < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'

      # Update core fields 
      execute("UPDATE core_fields SET field_type = 'drop_down', help_text = NULL WHERE key = 'morbidity_event[labs][lab_results][test_type]'") 
      execute("UPDATE core_fields SET field_type = 'drop_down', help_text = NULL WHERE key = 'contact_event[labs][lab_results][test_type]'") 

      execute("UPDATE core_fields SET key = 'morbidity_event[labs][lab_results][specimen_sent_to_state]' WHERE key = 'morbidity_event[labs][lab_results][specimen_sent_to_uphl]'") 
      execute("UPDATE core_fields SET key = 'contact_event[labs][lab_results][specimen_sent_to_state]' WHERE key = 'contact_event[labs][lab_results][specimen_sent_to_uphl]'") 

      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Test result', false, false, 'drop_down', 'morbidity_event', 'morbidity_event[labs][lab_results][test_result]')") 
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Test result', false, false, 'drop_down', 'contact_event', 'contact_event[labs][lab_results][test_result]')") 

      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Result value', false, false, 'single_line_text', 'morbidity_event', 'morbidity_event[labs][lab_results][result_value]')") 
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Result value', false, false, 'single_line_text', 'contact_event', 'contact_event[labs][lab_results][result_value]')") 

      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Units', false, false, 'single_line_text', 'morbidity_event', 'morbidity_event[labs][lab_results][units]')") 
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Units', false, false, 'single_line_text', 'contact_event', 'contact_event[labs][lab_results][units]')") 

      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Test status', false, false, 'drop_down', 'morbidity_event', 'morbidity_event[labs][lab_results][test_status]')") 
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Test status', false, false, 'drop_down', 'contact_event', 'contact_event[labs][lab_results][test_status]')") 

      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Comment', false, false, 'single_line_text', 'morbidity_event', 'morbidity_event[labs][lab_results][comment]')") 
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key) 
                VALUES ('Lab results | Comment', false, false, 'single_line_text', 'contact_event', 'contact_event[labs][lab_results][comment]')") 

      execute("DELETE FROM core_fields WHERE key = 'morbidity_event[labs][lab_results][lab_result_text]'") 
      execute("DELETE FROM core_fields WHERE key = 'contact_event[labs][lab_results][lab_result_text]'") 

      execute("DELETE FROM core_fields WHERE key = 'morbidity_event[labs][lab_results][interpretation]'") 
      execute("DELETE FROM core_fields WHERE key = 'contact_event[labs][lab_results][interpretation]'") 

      execute("DELETE FROM core_fields WHERE key = 'morbidity_event[labs][lab_results][test_detail]'") 
      execute("DELETE FROM core_fields WHERE key = 'contact_event[labs][lab_results][test_detail]'") 

      # Update CSV fields
      execute("DELETE FROM csv_fields WHERE long_name = 'lab_result_text'")
      execute("DELETE FROM csv_fields WHERE long_name = 'lab_test_detail'")
      execute("DELETE FROM csv_fields WHERE long_name = 'lab_interpretation'")
      
      execute("UPDATE csv_fields SET use_description = 'test_type.try(:common_name)' WHERE long_name = 'lab_test_type'")
      execute("UPDATE csv_fields
                 SET long_name = 'lab_specimen_sent_to_state',
                     use_description = 'specimen_sent_to_state.try(:common_name)',
                     use_code = 'specimen_sent_to_state.try(:the_code)'
                 WHERE long_name = 'lab_specimen_sent_to_uphl'")

      execute("INSERT INTO csv_fields (sort_order, export_group, long_name, use_description, short_name, use_code, event_type)
                VALUES (30, 'lab', 'lab_test_result', 'test_result.try(:code_description)', NULL, 'test_result.try(:the_code)', NULL)")
      execute("INSERT INTO csv_fields (sort_order, export_group, long_name, use_description, short_name, use_code, event_type)
                VALUES (40, 'lab', 'lab_result_value', 'result_value', NULL, NULL, NULL)")
      execute("INSERT INTO csv_fields (sort_order, export_group, long_name, use_description, short_name, use_code, event_type)
                VALUES (45, 'lab', 'lab_units', 'units', NULL, NULL, NULL)")
      execute("INSERT INTO csv_fields (sort_order, export_group, long_name, use_description, short_name, use_code, event_type)
                VALUES (60, 'lab', 'lab_test_status', 'test_status.try(:code_description)', NULL, 'test_status.try(:the_code)', NULL)")

      # Update System Codes
      # execute("INSERT INTO code_names (code_name, description, external) VALUES ('test_status', 'Lab Test Status', TRUE)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_status', 'I', 'Pending', 20)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_status', 'P', 'Preliminary result', 30)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_status', 'F', 'Final', 40)")
      
      # execute("INSERT INTO code_names (code_name, description, external) VALUES ('test_result', 'Lab Test Results', TRUE)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'POSITIVE', 'Positive / Reactive', 10)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'NEGATIVE', 'Negative / Non-reactive', 20)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'PRESUMPTIVE', 'Presumptive reactive', 30)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'TITER', 'Titer / Antibody present', 40)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'EQUIVOCAL', 'Equivocal / Borderline', 50)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'INDETERMINATE', 'Indeterminate', 60)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'REPEAT_REACT', 'Repeatedly reactive', 70)")
      execute("INSERT INTO external_codes (code_name, the_code, code_description, sort_order) VALUES ('test_result', 'OTHER', 'Other / Unknown', 80)")

      # Add new privs
      execute("INSERT INTO privileges (priv_name) VALUES ('manage_staged_message')")
      execute("INSERT INTO privileges (priv_name) VALUES ('write_staged_message')")

      #########  STILL TO DO #############
      # 
      # Update actual lab results
      # Delete now unused system codes
      
    end
  end

  def self.down
  end
end
