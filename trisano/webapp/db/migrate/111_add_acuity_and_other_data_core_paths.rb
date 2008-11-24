class AddAcuityAndOtherDataCorePaths < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      CoreField.create(field)
    end
  end

  def self.down
  end

  def self.core_fields
    [#morbidity events
     {:key => "morbidity_event[acuity]", :field_type => 'single_line_text', :name => 'Acuity', :can_follow_up => true, :event_type => 'morbidity_event'},
     {:key => "morbidity_event[other_data_1]", :field_type => 'single_line_text', :name => 'Other Data (First Field)', :can_follow_up => true, :event_type => 'morbidity_event'},
     {:key => "morbidity_event[other_data_2]", :field_type => 'single_line_text', :name => 'Other Data (Second Field)', :can_follow_up => true, :event_type => 'morbidity_event'}
    ]
  end
end
