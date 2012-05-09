class PopulateAssessmentEventCoreFields < ActiveRecord::Migration
  # We must collect the existing core fields for morbidyt events and then duplicate them for 
  # assessment events
  def self.up
    assessment_core_fields = CoreField.find(:all, :conditions => ["event_type = ?", "assessment_event"])
    
    # We only want to load assessment core fields from morbidity core fields
    # unless they've been defined.
    if assessment_core_fields.empty?

      morbidity_core_fields = CoreField.find(:all, :conditions => ["event_type = ?", "morbidity_event"])

      morbidity_core_fields.each do |field|
        new_field = core_field_to_hash(field)
        new_field['event_type'].gsub!("morbidity", "assessment")
        new_field['key'].gsub!("morbidity", "assessment")
        new_field['parent_key'].gsub!("morbidity", "assessment") unless new_field['parent_key'].nil?

        new_field_formatted = new_field.to_yaml
        new_field_formatted.gsub!("--- \n", "- ")
        new_field_formatted.gsub!("\n", "\n  ")

        CoreField.load!([new_field])

      end
    else
      say "Assessment core fields already defined.  No action taken."
    end
  end

  def self.down
    CoreField.destroy_all(["event_type = ?", "assessment_event"])
  end

  def self.core_field_to_hash(core_field)
    hash = {}
    values = %w(help_text fb_accessible can_follow_up field_type event_type key)
    values.each do |value|
      hash[value.to_s] = core_field.send(value.to_sym)
    end
    return hash
  end
end
