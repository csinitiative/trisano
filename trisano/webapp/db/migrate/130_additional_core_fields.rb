class AdditionalCoreFields < ActiveRecord::Migration
  def self.up
    add_column :core_fields, :fb_accessible, :boolean

    if RAILS_ENV == 'production'
      CoreField.update_all("fb_accessible=true")

      core_fields.each do |field|
        CoreField.create(field)
      end
    end
  end

  def self.down
  end

  def self.core_fields
    [
      { :key => "morbidity_event[lab_result][lab_name]",
        :name => "Lab results | Lab name",
        :event_type => "morbidity_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][test_type]",
        :name => "Lab results | Test type",
        :event_type => "morbidity_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][test_detail]",
        :name => "Lab results | Test detail",
        :event_type => "morbidity_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][lab_result_text]",
        :name => "Lab results | Test result",
        :event_type => "morbidity_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][reference_range]",
        :name => "Lab results | Reference range",
        :event_type => "morbidity_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][interpretation]",
        :name => "Lab results | Interpretation",
        :event_type => "morbidity_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][specimen_source]",
        :name => "Lab results | Specimen source",
        :event_type => "morbidity_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][collection_date]",
        :name => "Lab results | Collection date",
        :event_type => "morbidity_event",
        :field_type => "date",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][lab_test_date]",
        :name => "Lab results | Lab Test date",
        :event_type => "morbidity_event",
        :field_type => "date",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "morbidity_event[lab_result][specimen_sent_to_uphl]",
        :name => "Lab results | Specimen sent to UPHL",
        :event_type => "morbidity_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][lab_name]",
        :name => "Lab results | Lab name",
        :event_type => "contact_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][test_type]",
        :name => "Lab results | Test type",
        :event_type => "contact_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][test_detail]",
        :name => "Lab results | Test detail",
        :event_type => "contact_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][lab_result_text]",
        :name => "Lab results | Test result",
        :event_type => "contact_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][reference_range]",
        :name => "Lab results | Reference range",
        :event_type => "contact_event",
        :field_type => "single_line_text",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][interpretation]",
        :name => "Lab results | Interpretation",
        :event_type => "contact_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][specimen_source]",
        :name => "Lab results | Specimen source",
        :event_type => "contact_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][collection_date]",
        :name => "Lab results | Collection date",
        :event_type => "contact_event",
        :field_type => "date",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][lab_test_date]",
        :name => "Lab results | Lab Test date",
        :event_type => "contact_event",
        :field_type => "date",
        :fb_accessible => false,
        :can_follow_up => false },

      { :key => "contact_event[lab_result][specimen_sent_to_uphl]",
        :name => "Lab results | Specimen sent to UPHL",
        :event_type => "contact_event",
        :field_type => "drop_down",
        :fb_accessible => false,
        :can_follow_up => false }
    ]
  end
end
