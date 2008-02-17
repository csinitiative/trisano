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
  
  before_save :generate_record_id, :generate_mmwr

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
    #TODO need to get last RecordNumber
    if self.record_number.blank?
      t = Time.now        
      self.record_number = RecordNumber.new(Date.new(t.year, t.month, t.day), rand(99999)).value    
    end
  end  
  
  def generate_mmwr
    epi_dates = { :onsetdate => @disease.disease_onset_date, 
      :diagnosisdate => @disease.date_diagnosed, 
      :labresultdate => @lab_result.lab_test_date, 
      :firstreportdate => self.first_reported_PH_date }
    mmwr = Mmwr.new(epi_dates)
    
    self.MMWR_week = mmwr.mmwr_week
    self.MMWR_year = mmwr.mmwr_year
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
