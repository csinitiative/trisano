require 'chronic'

class Event < ActiveRecord::Base
  include Blankable

  belongs_to :event_type, :class_name => 'Code'
  belongs_to :event_status, :class_name => 'Code'
  belongs_to :imported_from, :class_name => 'Code'
  belongs_to :event_case_status, :class_name => 'Code'
  belongs_to :outbreak_associated, :class_name => 'Code'
  belongs_to :investigation_LHD_status, :class_name => 'Code'

  has_many :lab_results, :order => 'created_at', :dependent => :delete_all
  has_many :disease_events, :order => 'created_at', :dependent => :delete_all

  has_many :participations

# For reasons unknown code like the following won't work.
# has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Event.participation_code('Interested Party')]

  has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Interested Party").id]
  has_one :hospital, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Hospitalized At").id]
  has_one :jurisdiction, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Jurisdiction").id]
  has_one :reporting_agency, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reporting Agency").id]
  has_one :reporter, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reported By").id]

  validates_date :event_onset_date

  before_validation_on_create :save_associations
  after_validation :clear_base_error
  
  before_save :generate_mmwr
  before_create :set_record_number

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

  ### Participations
  # For all secondary (non-patient) participations this code will ultimately need to populate the primary_entity field with the patient's ID.
  
  def active_patient
    @active_patient || patient
  end

  def active_patient=(attributes)
    if new_record?
      @active_patient = Participation.new(attributes)
      @active_patient.role_id = Event.participation_code('Interested Party')
    else
      active_patient.update_attributes(attributes)
    end
  end
  
  def active_hospital
    @active_hospital || hospital
  end

  def active_hospital=(attributes)
    if new_record?
      @active_hospital = Participation.new(attributes)
      @active_hospital.role_id = Event.participation_code('Hospitalized At')
    else
      unless attributes.values_blank?
        if active_hospital.nil?
          attributes[:role_id] = Event.participation_code('Hospitalized At')
          self.create_hospital(attributes)
        else
          active_hospital.update_attributes(attributes)
        end
      end
    end
  end

  def active_jurisdiction
    @active_jurisdiction || jurisdiction
  end

  # Ultimately need to populate the primary_entity field with the patient's ID.
  def active_jurisdiction=(attributes)
    if new_record?
      @active_jurisdiction = Participation.new(attributes)
      @active_jurisdiction.role_id = Event.participation_code('Jurisdiction')
    else
      unless attributes.values_blank?
        if active_jurisdiction.nil?
          attributes[:role_id] = Event.participation_code('Jurisdiction')
          self.create_jurisdiction(attributes)
        else
          active_jurisdiction.update_attributes(attributes)
        end
      end
    end
  end

  def active_reporting_agency
    @active_reporting_agency || reporting_agency
  end

  def active_reporting_agency=(attributes)
    if attributes.values_blank? # User did nothing
    elsif attributes[:secondary_entity_id].blank? # User entered a new agency
      attributes.delete('secondary_entity_id')
      attributes[:active_secondary_entity][:entity_type] = 'place'
      attributes[:active_secondary_entity][:place][:place_type_id] = Code.other_place_type_id
    else                                       # User selected an existing entity
      attributes.delete('active_secondary_entity')
    end

    if new_record?
      @active_reporting_agency = Participation.new(attributes)
      @active_reporting_agency.role_id = Event.participation_code('Reporting Agency')
    else
      unless attributes.values_blank?
        if active_reporting_agency.nil?
          attributes[:role_id] = Event.participation_code('Reporting Agency')
          self.create_reporting_agency(attributes)
        else
          active_reporting_agency.update_attributes(attributes)
        end
      end
    end
  end

  def active_reporter
    @active_reporter || reporter
  end

  def active_reporter=(attributes)
    if new_record?
      @active_reporter = Participation.new(attributes)
      @active_reporter.role_id = Event.participation_code('Reported By')
    else
      unless attributes.values_blank?
        if active_reporter.nil?
          attributes[:role_id] = Event.participation_code('Reported By')
          self.create_reporter(attributes)
        else
          active_reporter.update_attributes(attributes)
        end
      end
    end
  end

  ### End participations

  def self.find_by_criteria(*args)
    
    options = args.extract_options!
    fulltext_terms = []
    where_clause = ""
    order_by_clause = "last_name, first_name ASC"
    issue_query = false
    
    if !options[:disease].blank?
      issue_query = true
      where_clause += "d.id = " + sanitize_sql(options[:disease])
    end
    
    if !options[:gender].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?

      if options[:gender] == "Unspecified"
        where_clause += "people.current_gender_id IS NULL"
      else
        where_clause += "people.current_gender_id = " + sanitize_sql(options[:gender])
      end
      
    end
    
    if !options[:investigation_status].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?

      if options[:investigation_status] == "Unspecified"
        where_clause += "e.\"investigation_LHD_status_id\" IS NULL"
      else
        where_clause += "e.\"investigation_LHD_status_id\" = " + sanitize_sql(options[:investigation_status])
      end
      
    end
    
    if !options[:city_id].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.city_id = " + options[:city_id].to_s
    end

    if !options[:county].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.county_id = " + sanitize_sql(options[:county])
    end
    
    if !options[:district].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.district_id = " + sanitize_sql(options[:district])
    end
    
    # Debt: The UI shows the user a format to use. Something a bit more robust
    # could be in place.
    if !options[:birth_date].blank?
      if (options[:birth_date].size == 4)
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "EXTRACT(YEAR FROM birth_date) = '" + sanitize_sql(options[:birth_date]) + "'"
        
      else
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "birth_date = '" + sanitize_sql(options[:birth_date]) + "'"
      end
      
    end
    
    if !options[:entered_on_start].blank? || !options[:entered_on_end].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:entered_on_start].blank? && !options[:entered_on_end].blank?
        where_clause += "e.created_at BETWEEN '" + sanitize_sql(options[:entered_on_start]) + 
          "' AND '" + sanitize_sql(options[:entered_on_end]) + "'"
      elsif !options[:entered_on_start].blank?
        where_clause += "e.created_at > '" + sanitize_sql(options[:entered_on_start]) + "'"
      else
        where_clause += "e.created_at < '" + sanitize_sql(options[:entered_on_end]) + "'"
      end
     
    end
    
    # Debt: The sql_term building is duplicated in Person. Where do you
    # factor out code common to models? Also, it may be that we don't 
    # need two different search avenues (CMR and People).
    if !options[:sw_last_name].blank? || !options[:sw_first_name].blank?
    
      issue_query = true
      
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:sw_last_name].blank?
        where_clause += "last_name ILIKE '" + sanitize_sql(options[:sw_last_name]) + "%'"
      end
      
      if !options[:sw_first_name].blank?
        where_clause += " AND " unless options[:sw_last_name].blank?
        where_clause += "first_name ILIKE '" + sanitize_sql(options[:sw_first_name]) + "%'"
      end
      
    elsif !options[:fulltext_terms].blank?
      issue_query = true
      soundex_codes = []
      raw_terms = options[:fulltext_terms].split(" ")
      
      raw_terms.each do |word|
        soundex_code = Text::Soundex.soundex(word)
        soundex_codes << soundex_code.downcase unless soundex_code.nil?
        fulltext_terms << sanitize_sql(["%s", word]).sub(",", "").downcase
      end
      
      fulltext_terms << soundex_codes unless soundex_codes.empty?
      sql_terms = fulltext_terms.join(" | ")
      
      where_clause += " AND " unless where_clause.empty?
      where_clause += "vector @@ to_tsquery('default', '#{sql_terms}')"
      order_by_clause = " rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
      
    end
    
    query = "SELECT people.entity_id, disease_events.event_id, first_name, last_name, middle_name, birth_date, 
                    disease_name, record_number, event_onset_date, c.code_description as gender, 
                    co.code_description as county, ci.code_description as city, cs.code_description as investigation,
                    di.code_description as district
                  FROM diseases d
                  INNER JOIN (SELECT DISTINCT ON(event_id) * FROM disease_events ORDER BY event_id, created_at DESC) disease_events on disease_events.disease_id = d.id
                  INNER JOIN participations p on p.event_id = disease_events.event_id
                  INNER JOIN (SELECT DISTINCT ON(entity_id) * FROM people ORDER BY entity_id, created_at DESC) people on p.primary_entity_id = entity_id
                  INNER JOIN events e on e.id = disease_events.event_id
                  LEFT OUTER JOIN codes c on c.id = people.current_gender_id
                  LEFT OUTER JOIN codes cs on cs.id = e.\"investigation_LHD_status_id\"
                  LEFT OUTER JOIN entities_locations el on el.entity_id = people.entity_id
                  LEFT OUTER JOIN locations l on l.id = el.location_id
                  LEFT OUTER JOIN addresses a on a.location_id = l.id
                  LEFT OUTER JOIN codes co on co.id = a.county_id
                  LEFT OUTER JOIN codes di on di.id = a.district_id
                  LEFT OUTER JOIN codes ci on ci.id = a.city_id
                  WHERE #{where_clause}
                  ORDER BY #{order_by_clause}"
    
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
    participations << @active_patient
    disease_events << @disease unless Utilities::model_empty?(@disease)
    lab_results << @lab_result unless Utilities::model_empty?(@lab_result)
    participations << @active_hospital unless @active_hospital.secondary_entity_id.blank? and Utilities::model_empty?(@active_hospital.hospitals_participation)
    participations << @active_jurisdiction unless @active_jurisdiction.secondary_entity_id.blank?
    participations << @active_reporting_agency unless @active_reporting_agency.secondary_entity_id.blank? and @active_reporting_agency.active_secondary_entity.place.name.blank?
    participations << @active_reporter unless Utilities::model_empty?(@active_reporter.active_secondary_entity.person)
  end

  def clear_base_error
    errors.delete(:disease_events)
    errors.delete(:lab_results)
    errors.delete(:participations)
  end

end
