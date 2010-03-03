class AddOrganismFieldRefs < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key)
                VALUES ('Lab results | Organism', false, false, 'drop_down', 'morbidity_event', 'morbidity_event[labs][lab_results][organism]')")
      execute("INSERT INTO core_fields (name, fb_accessible, can_follow_up, event_type, field_type, key)
                VALUES ('Lab results | Organism', false, false, 'drop_down', 'contact_event', 'contact_event[labs][lab_results][organism]')")
      execute("INSERT INTO csv_fields (sort_order, export_group, long_name, use_description, short_name, use_code, event_type)
                VALUES (25, 'lab', 'lab_organism', 'organism.try(:organism_name)', NULL, NULL, NULL)")
    end
  end

  def self.down
  end
end
