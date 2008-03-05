require 'chronic'

class Event < ActiveRecord::Base

  belongs_to :event_type, :class_name => 'Code'
  belongs_to :event_status, :class_name => 'Code'
  belongs_to :imported_from, :class_name => 'Code'
  belongs_to :event_case_status, :class_name => 'Code'
  belongs_to :outbreak_associated, :class_name => 'Code'
  belongs_to :investigation_LHD_status, :class_name => 'Code'

  has_many :lab_results, :order => 'created_at', :dependent => :delete_all
  has_many :disease_events, :order => 'created_at', :dependent => :delete_all

  has_many :participations

# For reasons unknown the following 2 lines don't work.
#  has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Event.participation_code('Interested Party')]
#  has_one :hospital, :class_name => 'Participation', :conditions => ["role_id = ?", Event.participation_code('Hospitalized At')]
  has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Interested Party").id]
  has_one :hospital, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Hospitalized At").id]

  validates_date :event_onset_date

  before_validation :save_associations
  after_validation :clear_base_error
  
  before_save :generate_mmwr
  before_create :set_record_number

  def active_patient
    @active_patient || patient
  end

  def active_patient=(attributes)
    @active_patient = Participation.new(attributes)
    @active_patient.role_id = Event.participation_code('Interested Party')
  end

  def active_hospital
    @active_hospital || hospital
  end

  # Ultimately need to populate the primary_entity field with the patient's ID.
  def active_hospital=(attributes)
    if new_record?
      @active_hospital = Participation.new(attributes)
      @active_hospital.role_id = Event.participation_code('Hospitalized At')
    else
      active_hospital.update_attributes(attributes)
    end
  end

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

  def jurisdiction
  end

  def jurisdiction=
  end

  def reporting_agency
  end

  def reporting_agency=
  end

  def self.find_by_criteria(*args)
    options = args.extract_options!
    where_clause = ""
    order_by_clause = ""
    
    if !options[:disease].blank?
      issue_query = true
      where_clause += "d.id = " + sanitize_sql(options[:disease])
    end
    
    query = "select disease_events.event_id, first_name, last_name, middle_name, disease_name, record_number, event_onset_date, code_description
                  from diseases d
                  inner join (SELECT DISTINCT ON(event_id) * FROM disease_events ORDER BY event_id, created_at DESC) disease_events on disease_events.disease_id = d.id
                  inner join participations p on p.event_id = disease_events.event_id
                  inner join (SELECT DISTINCT ON(entity_id) * FROM people ORDER BY entity_id, created_at DESC) people on p.primary_entity_id = entity_id
                  inner join events e on e.id = disease_events.event_id
                  left outer join entities_locations el on el.entity_id = people.entity_id
                  left outer join locations l on l.id = el.location_id
                  left outer join addresses a on a.location_id = l.id
                  left outer join codes c on c.id = a.county_id
                  WHERE #{where_clause}
                  ORDER BY last_name"
    
    find_by_sql(query) if issue_query
  end

  private
  
  def self.participation_code(description)
    Code.find_by_code_name_and_code_description('participant', description).id
  end

  def set_record_number
    customer_number_sequence = 'events_record_number_seq'
    record_number = connection.select_value("select nextval('#{customer_number_sequence}')")
    self.record_number = record_number
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
    participations << @active_patient unless @active_patient.nil? # Change this when patients are edited along with CMRs
    participations << @active_hospital unless @active_hospital.nil?
  end

  def clear_base_error
    errors.delete(:disease_events)
    errors.delete(:lab_results)
    errors.delete(:participations)
  end

end
