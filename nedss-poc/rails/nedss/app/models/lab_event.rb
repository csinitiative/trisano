require 'chronic'

class LabEvent < ActiveRecord::Base
  set_table_name :events

  belongs_to :event_type, :class_name => 'Code'
  belongs_to :event_status, :class_name => 'Code'

  # There are other codes too, but leaving them out for now
  # event_status, imported_from, event_case_status

  has_many :disease_events, :foreign_key => 'event_id', :order => 'created_at', :dependent => :delete_all
  has_many :lab_results, :foreign_key => 'event_id', :order => 'created_at', :dependent => :delete_all

  has_many :participations, :foreign_key => 'event_id'

  validates_date :event_onset_date

  before_validation :save_associations
  after_validation :clear_base_error
  
  before_save :generate_record_id

  def disease
    @disease || disease_events.last
  end

  def disease=(attributes)
    @disease = DiseaseEvent.new(attributes)
  end  

  def lab_result
    @lab_result || lab_results.last
  end

  def lab_result=(attributes)
    @lab_result = LabResult.new(attributes)
  end

  private
  
  def generate_record_id
    t = Time.now    
    self.record_number = RecordId.new(Date.new(t.year, t.month, t.day), 5).value    
  end  

  def save_associations
    disease_events << @disease
    lab_results << @lab_result
  end

  def clear_base_error
    errors.delete(:disease_events)
    errors.delete(:lab_results)
  end
end
