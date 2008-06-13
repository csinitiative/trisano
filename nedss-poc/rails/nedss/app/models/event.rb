class Event < ActiveRecord::Base
  include Blankable

  belongs_to :event_type, :class_name => 'Code'
  belongs_to :event_status, :class_name => 'Code'
  belongs_to :imported_from, :class_name => 'Code'
  belongs_to :event_case_status, :class_name => 'Code'
  belongs_to :outbreak_associated, :class_name => 'Code'
  belongs_to :investigation_LHD_status, :class_name => 'Code'

  has_many :lab_results, :order => 'created_at ASC', :dependent => :delete_all
  has_many :disease_events, :order => 'created_at ASC', :dependent => :delete_all

  has_many :participations
  has_many :form_references
  has_many :answers

  # For reasons unknown code like the following won't work.
  # has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Event.participation_code('Interested Party')]

  has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Interested Party").id]
  has_one :hospital, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Hospitalized At").id]
  has_one :jurisdiction, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Jurisdiction").id]
  has_one :reporting_agency, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reporting Agency").id]
  has_one :reporter, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reported By").id]

  has_many :contacts, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Contact").id]

  validates_date :event_onset_date

  before_validation_on_create :save_associations
  after_validation :clear_base_error
  
  before_save :generate_mmwr
  before_create :set_record_number

  def disease
    @disease ||= disease_events.last
  end

  def disease=(attributes)
    if new_record?
      @disease = DiseaseEvent.new(attributes)
    else
      disease_events.build(attributes) unless attributes.values_blank?
    end
  end  

  def form_references=(attributes)
    if form_references.empty?
      form_references.build(attributes)
    else
      form_references.update(attributes.keys, attributes.values)
    end
  end

  def answers=(attributes)      
    if answers.empty?
      answers.build(attributes.values)
    else
      answers.update(attributes.keys, attributes.values)
    end
  end
  
  def new_answers=(attributes)
    answers.build(attributes)
  end

  def get_or_initialize_answer(question_id)
    answers.detect(lambda { Answer.new(:question_id => question_id) } ) { |answer_object| answer_object.question_id == question_id }
  end

  def lab_result
    @lab_result ||= lab_results.last
  end

  def lab_result=(attributes)
    if new_record?
      @lab_result = LabResult.new(attributes)
    else
      lab_results.build(attributes) unless attributes.values_blank?
    end
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
  
  def active_contacts
    @active_contacts || contacts
  end

  def new_contact
    @new_contact || self.new_contact = {}
  end

  def new_contact=(attributes)
    if attributes.empty?
      @new_contact = Participation.new(attributes) 
      @new_contact.role_id = Event.participation_code('Contact')
      @new_contact.active_secondary_entity = {}
      @new_contact
    else
      unless attributes[:active_secondary_entity][:person][:last_name].blank?
        attributes[:role_id] = Event.participation_code('Contact')
        contacts.build(attributes)
      end
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

  # Debt: Consolidate sanitize_sql calls where possible
  def self.find_by_criteria(*args)
    
    options = args.extract_options!
    fulltext_terms = []
    where_clause = ""
    order_by_clause = "p3.primary_last_name, p3.primary_first_name ASC"
    issue_query = false
    
    if !options[:disease].blank?
      issue_query = true
      where_clause += "p3.disease_id = " + sanitize_sql(["%s", options[:disease]])
    end
    
    if !options[:gender].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?

      if options[:gender] == "Unspecified"
        where_clause += "p3.primary_birth_gender_id IS NULL"
      else
        where_clause += "p3.primary_birth_gender_id = " + sanitize_sql(["%s", options[:gender]])
      end
      
    end
    
    if !options[:investigation_status].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?

      if options[:investigation_status] == "Unspecified"
        where_clause += "p3.investigation_LHD_status_id IS NULL"
      else
        where_clause += "p3.investigation_LHD_status_id = " + sanitize_sql(["%s", options[:investigation_status]])
      end
      
    end
    
    if !options[:city].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.city ILIKE '" + sanitize_sql(["%s", options[:city]]) + "%'"
    end

    if !options[:county].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "a.county_id = " + sanitize_sql(["%s", options[:county]])
    end
    
    if !options[:jurisdiction_id].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "p3.jurisdiction_id = " + sanitize_sql(["%s", options[:jurisdiction_id]])
    else
      where_clause += " AND " unless where_clause.empty?
      allowed_jurisdiction_ids =  User.current_user.jurisdictions_for_privilege(:view).collect   {|j| j.entity_id}
      allowed_jurisdiction_ids += User.current_user.jurisdictions_for_privilege(:update).collect {|j| j.entity_id}
      allowed_ids_str = allowed_jurisdiction_ids.uniq!.inject("") { |str, entity_id| str += "#{entity_id}," }
      where_clause += "p3.jurisdiction_id IN (" + allowed_ids_str.chop + ")"
    end
    
    # Debt: The UI shows the user a format to use. Something a bit more robust
    # could be in place.
    if !options[:birth_date].blank?
      if (options[:birth_date].size == 4 && options[:birth_date].to_i != 0)
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "EXTRACT(YEAR FROM p3.primary_birth_date) = '" + sanitize_sql(["%s",options[:birth_date]]) + "'"
      else
        issue_query = true
        where_clause += " AND " unless where_clause.empty?
        where_clause += "p3.primary_birth_date = '" + sanitize_sql(["%s", options[:birth_date]]) + "'"
      end
      
    end
    
    # Problem?
    if !options[:entered_on_start].blank? || !options[:entered_on_end].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:entered_on_start].blank? && !options[:entered_on_end].blank?
        where_clause += "p3.created_at BETWEEN '" + sanitize_sql(["%s", options[:entered_on_start]]) + 
          "' AND '" + sanitize_sql(options[:entered_on_end]) + "'"
      elsif !options[:entered_on_start].blank?
        where_clause += "p3.created_at > '" + sanitize_sql(["%s", options[:entered_on_start]]) + "'"
      else
        where_clause += "p3.created_at < '" + sanitize_sql(["%s", options[:entered_on_end]]) + "'"
      end
     
    end
    
    # Debt: The sql_term building is duplicated in Person. Where do you
    # factor out code common to models? Also, it may be that we don't 
    # need two different search avenues (CMR and People).
    if !options[:sw_last_name].blank? || !options[:sw_first_name].blank?
    
      issue_query = true
      
      where_clause += " AND " unless where_clause.empty?
      
      if !options[:sw_last_name].blank?
        where_clause += "p3.primary_last_name ILIKE '" + sanitize_sql(["%s", options[:sw_last_name]]) + "%'"
      end
      
      if !options[:sw_first_name].blank?
        where_clause += " AND " unless options[:sw_last_name].blank?
        where_clause += "p3.primary_first_name ILIKE '" + sanitize_sql(["%s", options[:sw_first_name]]) + "%'"
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
    
    query = "
    SELECT 
           p3.event_id, 
           p3.primary_entity_id AS entity_id,
           p3.primary_first_name AS first_name,
           p3.primary_middle_name AS middle_name,
           p3.primary_last_name AS last_name,
           p3.primary_birth_date AS birth_date,
           p3.disease_id,
           p3.disease_name,
           p3.primary_record_number AS record_number,
           p3.event_onset_date,
           p3.primary_birth_gender_id AS birth_gender_id,
           p3.investigation_lhd_status_id,
           p3.jurisdiction_id,
           p3.jurisdiction_name, 
           p3.vector,
           p3.created_at,
           c.code_description AS gender,
           cs.code_description AS lhd_investigation_status, 
           a.city, 
           co.code_description AS county
    FROM 
           ( SELECT 
                    p1.event_id, p1.primary_entity_id, p1.vector, p1.primary_first_name, p1.primary_middle_name, p1.primary_last_name,
                    p1.primary_birth_date, p1.disease_id, p1.disease_name, p1.primary_record_number, p1.event_onset_date, p1.primary_birth_gender_id,
                    p1.investigation_lhd_status_id, p1.created_at, p2.jurisdiction_id, p2.jurisdiction_name
             FROM 
                    ( SELECT 
                             p.event_id as event_id, people.vector as vector, people.entity_id as primary_entity_id, people.first_name as primary_first_name,
                             people.last_name as primary_last_name, people.middle_name as primary_middle_name, people.birth_date as primary_birth_date,
                             d.id as disease_id, d.disease_name as disease_name, record_number as primary_record_number, event_onset_date as event_onset_date,
                             people.birth_gender_id as primary_birth_gender_id,
                             e.\"investigation_LHD_status_id\" as investigation_lhd_status_id,
                             e.created_at
                      FROM   
                             events e
                      INNER JOIN  
                             participations p on p.event_id = e.id
                      INNER JOIN 
                             ( SELECT DISTINCT ON
                                      (entity_id) *
                               FROM
                                      people
                               ORDER BY entity_id, created_at DESC
                              ) AS people
                                ON people.entity_id = p.primary_entity_id
                      LEFT OUTER JOIN 
                            ( SELECT DISTINCT ON 
                                     (event_id) * 
                              FROM   
                                     disease_events 
                              ORDER BY event_id, created_at DESC
                            ) AS disease_events 
                              ON disease_events.event_id = e.id
                      LEFT OUTER JOIN 
                            diseases d ON disease_events.disease_id = d.id
                      WHERE  
                            p.primary_entity_id IS NOT NULL 
                      AND   p.secondary_entity_id IS NULL
                    ) AS p1
             FULL OUTER JOIN 
                   (
                     SELECT 
                            secondary_entity_id AS jurisdiction_id, 
                            j.name AS jurisdiction_name,
                            p.event_id AS event_id
                     FROM   
                            events e
                     INNER JOIN 
                            participations p ON p.event_id = e.id
                     LEFT OUTER JOIN 
                            codes c ON c.id = p.role_id
                     LEFT OUTER JOIN 
                           ( SELECT DISTINCT ON 
                                    (entity_id) entity_id, 
                                    name 
                             FROM 
                                    places 
                             ORDER BY 
                                    entity_id, created_at DESC
                           ) AS j ON j.entity_id = p.secondary_entity_id
                     WHERE  c.code_description = 'Jurisdiction'
                   ) AS p2 ON p1.event_id = p2.event_id
           ) AS p3
    LEFT OUTER JOIN 
           ( SELECT DISTINCT ON 
                    (entity_id) entity_id, location_id
             FROM
                    entities_locations, codes
             WHERE
                    codes.code_name = 'yesno'  
             AND
                    codes.the_code = 'Y'
             AND
                    entities_locations.primary_yn_id = codes.id
             ORDER BY
                    entity_id, created_at DESC
           ) AS el ON el.entity_id = p3.primary_entity_id
    LEFT OUTER JOIN 
           locations l ON l.id = el.location_id
    LEFT OUTER JOIN 
           addresses a ON a.location_id = l.id
    LEFT OUTER JOIN 
           codes co ON co.id = a.county_id
    LEFT OUTER JOIN 
           codes c ON c.id = p3.primary_birth_gender_id
    LEFT OUTER JOIN 
           codes cs ON cs.id = p3.investigation_lhd_status_id
    WHERE 
           #{where_clause}
    ORDER BY 
           #{order_by_clause}"
    
    find_by_sql(query) if issue_query
  end

  def under_investigation?
    true if event_status_id == Code.find_by_code_name_and_code_description("eventstatus", "Under Investigation").id
  end

  def reopened?
    true if event_status_id == Code.find_by_code_name_and_code_description("eventstatus", "Reopened").id
  end
  
  def get_investigation_forms
    if self.form_references.empty?
      i = -1
      Form.get_published_investigation_forms(self.disease.disease_id, self.active_jurisdiction.secondary_entity_id).each do |form|
        self.form_references[i += 1] = FormReference.new(:form_id => form.id)
      end
    end
  end
  
  def Event.exposed_attributes
    {
      "event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name" },
      "event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name" },
      "event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name" },
      "event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number" },
      "event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name" },
      "event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number" },
      "event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city" },
      "event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
      "event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
      "event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
      "event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of Birth" },
      "event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
      "event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },
      "event[active_patient][active_primary_entity][telephone][area_code]" => {:type => :single_line_text, :name => "Patient area code" },
      "event[active_patient][active_primary_entity][telephone][phone_number]" => {:type => :single_line_text, :name => "Patient phone number" },
      "event[active_patient][active_primary_entity][telephone][extension]" => {:type => :single_line_text, :name => "Patient extension" },
      "event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
      "event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
      "event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" }
      
      # "event[active_patient][active_primary_entity][race_ids][]" => {:type => :single_line_text, :name => "Patient race" },
    }
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
    epi_dates = { :onsetdate => @disease.nil? ? nil : @disease.disease_onset_date, 
      :diagnosisdate => @disease.nil? ? nil : @disease.date_diagnosed, 
      :labresultdate => @lab_result.nil? ? nil : @lab_result.lab_test_date, 
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
    errors.delete(:answers)
  end

end
