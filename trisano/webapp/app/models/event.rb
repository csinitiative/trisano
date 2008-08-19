# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class Event < ActiveRecord::Base
  include Blankable

  belongs_to :event_status, :class_name => 'ExternalCode'
  belongs_to :imported_from, :class_name => 'ExternalCode'
  belongs_to :lhd_case_status, :class_name => 'ExternalCode'
  belongs_to :udoh_case_status, :class_name => 'ExternalCode'
  belongs_to :outbreak_associated, :class_name => 'ExternalCode'

  has_many :disease_events, :order => 'created_at ASC', :dependent => :delete_all
  has_many :participations
  has_many :form_references
  has_many :answers

  has_many :labs, :class_name => 'Participation', 
    :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Tested By").id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :hospitalized_health_facilities, :class_name => 'Participation', 
    :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Hospitalized At").id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :diagnosing_health_facilities, :class_name => 'Participation', 
    :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Diagnosed At").id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :contacts, :class_name => 'Participation',  
    :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Contact").id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :clinicians, :class_name => 'Participation', 
    :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Treated By").id]

  has_one :patient,  :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Interested Party").id]
  has_one :jurisdiction, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Jurisdiction").id]
  has_one :reporting_agency, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reporting Agency").id]
  has_one :reporter, :class_name => 'Participation', :conditions => ["role_id = ?", Code.find_by_code_name_and_code_description('participant', "Reported By").id]

  validates_date :event_onset_date
  validates_associated :labs
  validates_associated :hospitalized_health_facilities
  validates_associated :diagnosing_health_facilities
  validates_associated :contacts
  validates_associated :participations

  before_validation_on_create :save_associations, :set_event_onset_date
  
  after_update :save_multiples
  before_save :generate_mmwr
  before_create :set_record_number

  class << self
    def accept_reject_actions
      ExternalCode.find_all_by_code_name('eventstatus').select do |event_action|
        rv = false
        case event_action.the_code
        when 'ACPTD-LHD'
          event_action.code_description = "Accept"
          rv = true
        when 'RJCTD-LHD'
          event_action.code_description = "Reject"
          rv = true
        end
        rv
      end
    end

    def map_state_id_to_priv(state_id)
      state = ExternalCode.find(state_id)
      priv = nil
      case state.the_code
      when 'ACPTD-LHD', 'RJCTD-LHD'
        priv = :accept_event_for_lhd
      end
      return priv
    end
  end

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
  
  def new_checkboxes=(attributes)
    attributes.each do |key, value|
      answer = Answer.new(:question_id => key, :check_box_answer => value[:check_box_answer])
      answers << answer
    end
  end
  
  def new_radio_buttons=(attributes)
    attributes.each do |key, value|
      answer = Answer.new(:question_id => key, :radio_button_answer => value[:radio_button_answer])
      answers << answer
    end
  end  

  def get_or_initialize_answer(question_id)
    answers.detect(lambda { Answer.new(:question_id => question_id) } ) { |answer_object| answer_object.question_id == question_id }
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
      # This is a bug!  Should be building these up in memory so they are subject to validation and transactions
      active_patient.update_attributes(attributes)
    end
  end
  
  def clinician
    @clinician ||= Participation.new( :role_id => Event.participation_code('Treated By'), :active_secondary_entity => {}) 
  end

  def clinician=(attributes)
    unless attributes[:active_secondary_entity][:person][:last_name].blank?
      attributes[:role_id] = Event.participation_code('Treated By')
      @clinician = clinicians.build(attributes)
    end
  end

  def new_telephone_attributes=(phone_attributes)
    phone_attributes.each do |attributes|
      code = attributes.delete(:entity_location_type_id)
      next if attributes.values_blank?
      el = active_patient.active_primary_entity.entities_locations.build(:entity_location_type_id => code, :primary_yn_id => ExternalCode.no_id)
      el.build_location.telephones.build(attributes)
    end
  end

  def existing_telephone_attributes=(phone_attributes)
    active_patient.active_primary_entity.telephone_entities_locations.reject(&:new_record?).each do |el|
      attributes = phone_attributes[el.id.to_s]
      if attributes
        attributes.delete(:entity_location_type_id)
        el.location.telephones.last.attributes = attributes
      else
        el.location.destroy
      end
    end
  end
  
  def new_hospital_attributes=(hospital_attributes)
    hospital_attributes.each do |attributes|
      next if attributes.values_blank?
      hospital_participation = hospitalized_health_facilities.build(:role_id => Event.participation_code('Hospitalized At'))
      # Hospitals are a drop down of existing places, not an autocomplete.  Just assgn.
      hospital_participation.secondary_entity_id = attributes.delete("secondary_entity_id")
      hospital_participation.build_hospitals_participation(attributes) unless attributes.values_blank?
    end
  end

  def existing_hospital_attributes=(hospital_attributes)
    hospitalized_health_facilities.reject(&:new_record?).each do |hospital|
      attributes = hospital_attributes[hospital.id.to_s]
      if attributes
        hospital.secondary_entity_id = attributes.delete("secondary_entity_id")
        unless attributes.values_blank?
          if hospital.hospitals_participation.nil?
            hospital.hospitals_participation = HospitalsParticipation.new(attributes)
          else
            hospital.hospitals_participation.attributes = attributes
          end
        end
      else
        hospitalized_health_facilities.delete(hospital)
      end
    end
  end

  def new_diagnostic_attributes=(diagnostic_attributes)
    diagnostic_attributes.each do |attributes|
      next if attributes.values_blank?
      diagnostic_participation = diagnosing_health_facilities.build(:role_id => Event.participation_code('Diagnosed At'))
      # Diagnostic facilities are a drop down of existing places, not an autocomplete.  Just assgn.
      diagnostic_participation.secondary_entity_id = attributes.delete("secondary_entity_id")
    end
  end

  def existing_diagnostic_attributes=(diagnostic_attributes)
    diagnosing_health_facilities.reject(&:new_record?).each do |diagnostic|
      attributes = diagnostic_attributes[diagnostic.id.to_s]
      if attributes
        diagnostic.secondary_entity_id = attributes.delete("secondary_entity_id")
      else
        diagnosing_health_facilities.delete(diagnostic)
      end
    end
  end

  def new_contact_attributes=(contact_attributes)
    contact_attributes.each do |attributes|
      next if attributes.values_blank?
      contact_participation = contacts.build(:role_id => Event.participation_code('Contact'))
      contact_entity = contact_participation.build_secondary_entity
      contact_entity.entity_type = "person"
      contact_entity.build_person_temp( attributes )
    end
  end

  def existing_contact_attributes=(contact_attributes)
    contacts.reject(&:new_record?).each do |contact|
      attributes = contact_attributes[contact.secondary_entity.person_temp.id.to_s]
      if attributes
        contact.secondary_entity.person_temp.attributes = attributes
      else
        contacts.delete(contact)
      end
    end
  end

  def new_lab_attributes=(lab_attributes)
    lab_attributes.each do |attributes|
      next if attributes.values_blank?

      lab_entity_id = attributes.delete("lab_entity_id")
      lab_name = attributes.delete("name")
      lab_name = nil if lab_name.blank?
      lab_participation = nil

      # If lab_entity_id has a value then the place already exists
      unless lab_entity_id.blank?
        # Check to see if there's an existing participation for the lab
        # We search the labs array, rather than use AR #find, so we can build the association in memory for the @event.save that's soon to come
        lab_participation = labs.detect { |lab| lab.secondary_entity_id == lab_entity_id.to_i }

        # Participation does not exist, create one and link to existing lab
        if lab_participation.nil?
          lab_participation = labs.build(:role_id => Event.participation_code('Tested By'))
          lab_participation.secondary_entity_id = lab_entity_id
        else
          # participation already exists, do nothing
        end
      else
        # New lab. Create participation, entity, and place, linking each to the next
        lab_participation = labs.build(:role_id => Event.participation_code('Tested By'))
        lab_entity = lab_participation.build_secondary_entity
        lab_entity.entity_type = "place"
        lab_entity.build_place_temp( {:name => lab_name, :place_type_id => Code.find_by_code_name_and_code_description("placetype", "Laboratory").id} )
      end

      # Build a new lab_result and associate with the participation
      lab_participation.lab_results.build(attributes)
    end
  end
  
  # We're not allowing editing lab names, just lab results
  def existing_lab_attributes=(lab_attributes)

    # loop through all lab participations and their lab_results, ignoring any just added by new_lab_attributes
    labs.reject(&:new_record?).each do |lab|
      lab.lab_results.reject(&:new_record?).each do |lab_result|

        # Note the "id" here is the lab_result ID, not the lab ID as in new_lab_attributes
        # If there are attributes for that ID, then the lab result has not been deleted, update the attributes in memory
        attributes = lab_attributes[lab_result.id.to_s]
        if attributes
          lab_result.attributes = attributes
        else
          # Array (not activerecord) deletion.  Make this a soft delete when we get to it
          lab.lab_results.delete(lab_result)
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
          # Bug!
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
          # Bug!
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
      unless attributes[:active_secondary_entity][:person][:last_name].blank? and attributes[:active_secondary_entity][:person][:first_name].blank?
        if active_reporter.nil?
          attributes[:role_id] = Event.participation_code('Reported By')
          self.create_reporter(attributes)
        else
          # Bug!
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
    where_clause = "p3.type = 'MorbidityEvent'"
    order_by_clause = "p3.primary_last_name, p3.primary_first_name ASC"
    issue_query = false
    
    if !options[:disease].blank?
      issue_query = true
      where_clause += " AND p3.disease_id = " + sanitize_sql(["%s", options[:disease]])
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
    
    if !options[:event_status].blank?
      issue_query = true
      where_clause += " AND " unless where_clause.empty?
      where_clause += "p3.event_status_id = " + sanitize_sql(["%s", options[:event_status]])
      
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
      allowed_jurisdiction_ids =  User.current_user.jurisdictions_for_privilege(:view_event).collect   {|j| j.entity_id}
      allowed_jurisdiction_ids += User.current_user.jurisdictions_for_privilege(:update_event).collect {|j| j.entity_id}
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
           p3.type, 
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
           p3.event_status_id,
           p3.jurisdiction_id,
           p3.jurisdiction_name, 
           p3.vector,
           p3.created_at,
           c.code_description AS gender,
           cs.code_description AS event_status, 
           a.city, 
           co.code_description AS county
    FROM 
           ( SELECT 
                    p1.event_id, p1.type, p1.primary_entity_id, p1.vector, p1.primary_first_name, p1.primary_middle_name, p1.primary_last_name,
                    p1.primary_birth_date, p1.disease_id, p1.disease_name, p1.primary_record_number, p1.event_onset_date, p1.primary_birth_gender_id,
                    p1.event_status_id, p1.created_at, p2.jurisdiction_id, p2.jurisdiction_name
             FROM 
                    ( SELECT 
                             p.event_id as event_id, people.vector as vector, people.entity_id as primary_entity_id, people.first_name as primary_first_name,
                             people.last_name as primary_last_name, people.middle_name as primary_middle_name, people.birth_date as primary_birth_date,
                             d.id as disease_id, d.disease_name as disease_name, record_number as primary_record_number, event_onset_date as event_onset_date,
                             people.birth_gender_id as primary_birth_gender_id,
                             e.event_status_id as event_status_id, e.type as type,
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
                    entities_locations, external_codes
             WHERE
                    external_codes.code_name = 'yesno'  
             AND
                    external_codes.the_code = 'Y'
             AND
                    entities_locations.primary_yn_id = external_codes.id
             ORDER BY
                    entity_id, entities_locations.created_at DESC
           ) AS el ON el.entity_id = p3.primary_entity_id
    LEFT OUTER JOIN 
           locations l ON l.id = el.location_id
    LEFT OUTER JOIN 
           addresses a ON a.location_id = l.id
    LEFT OUTER JOIN 
           external_codes co ON co.id = a.county_id
    LEFT OUTER JOIN 
           external_codes c ON c.id = p3.primary_birth_gender_id
    LEFT OUTER JOIN 
           codes cs ON cs.id = p3.event_status_id
    WHERE 
           #{where_clause}
    ORDER BY 
           #{order_by_clause}"
    
    find_by_sql(query) if issue_query
  end

  def under_investigation?
    event_status.event_under_investigation? unless event_status.nil?
  end

  def get_investigation_forms
    if self.form_references.empty?
      return if self.disease.nil? || self.disease.disease_id.blank?
      i = -1
      Form.get_published_investigation_forms(self.disease.disease_id, self.active_jurisdiction.secondary_entity_id).each do |form|
        self.form_references[i += 1] = FormReference.new(:form_id => form.id)
      end
    end
  end
  
  def route_to_jurisdiction(jurisdiction)
    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place
    transaction do
      proposed_jurisdiction = Entity.find(jurisdiction_id) # Will raise an exception if record not found
      raise "New jurisdiction is not a jurisdiction" if proposed_jurisdiction.current_place.place_type_id != Code.find_by_code_name_and_the_code('placetype', 'J').id
      active_jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
      update_attribute("event_status_id",  ExternalCode.find_by_code_name_and_the_code('eventstatus', "ASGD-LHD").id)
      reload # Any existing references to this object won't see these changes without this
    end
  end

  def Event.exposed_attributes
    {
      "morbidity_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name" },
      "morbidity_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name" },
      "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name" },
      "morbidity_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number" },
      "morbidity_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name" },
      "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number" },
      "morbidity_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city" },
      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state" },
      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county" },
      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth" },
      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age" },
      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death" },
      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender" },
      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity" },
      "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language" },
      # "morbidity_event[active_patient][active_primary_entity][race_ids][]" => {:type => :single_line_text, :name => "Patient race" }
      
      # Risk factors
      "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant" },
      "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "    Pregnancy due date" },
      "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler" },
      "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker" },
      "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living" },
      "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => " Day care association" },
      "morbidity_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation" },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors" },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes" },

      # Event-level fields
      "morbidity_event[results_reported_to_clinician_date]" => {:type => :single_line_text, :name => "Results reported to clinician date"},
      "morbidity_event[first_reported_PH_date]" => {:type => :single_line_text, :name => "Date first reported to public health"},
      "morbidity_event[lhd_case_status_id]" => {:type => :drop_down, :name => 'LHD case status'},
      "morbidity_event[udoh_case_status_id]" => {:type => :drop_down, :name => 'UDOH case status'},
      "morbidity_event[outbreak_associated_id]" => {:type => :drop_down, :name => 'Outbreak associated'},
      "morbidity_event[outbreak_name]" => {:type => :single_line_text, :name => 'Outbreak'},
      "morbidity_event[active_jurisdiction][secondary_entity_id]" => {:type => :multi_select, :name => 'Jurisdiction responsible for investigation'},
      "morbidity_event[event_status_id]" => {:type => :drop_down, :name => 'Event status'},
      "morbidity_event[investigation_started_date]" => {:type => :single_line_text, :name => 'Date investigation started'},
      "morbidity_event[investigation_completed_LHD_date]" => {:type => :single_line_text, :name => 'Date investigation completed'},
      "morbidity_event[event_name]" => {:type => :single_line_text, :name => 'Event name'},
      "morbidity_event[review_completed_UDOH_date]" => {:type => :single_line_text, :name => 'Date review completed by UDOH'},
      "morbidity_event[imported_from_id]" => {:type => :drop_down, :name => 'Imported from'},
     
      # Reporting-level fields
      "morbidity_event[active_reporting_agency][active_secondary_entity][place][name]" => {:type => :drop_down, :name => 'Reporting agency'},
      "morbidity_event[active_reporter][active_secondary_entity][person][first_name]" => {:type => :drop_down, :name => 'Reporter first name'},
      "morbidity_event[active_reporter][active_secondary_entity][person][last_name]" => {:type => :drop_down, :name => 'Reporter last name'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone_entities_location][entity_location_type_id]" => {:type => :drop_down, :name => 'Reporter phone type'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][area_code]" => {:type => :drop_down, :name => 'Reporter area code'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][phone_number]" => {:type => :drop_down, :name => 'Reporter phone number'},
      "morbidity_event[active_reporter][active_secondary_entity][telephone][extension]" => {:type => :drop_down, :name => 'Reporter extension'}
      
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
      #      :labresultdate => @lab.lab_result.nil? ? nil : @lab.lab_result.lab_test_date, 
      :firstreportdate => self.first_reported_PH_date }
    mmwr = Mmwr.new(epi_dates)
    
    self.MMWR_week = mmwr.mmwr_week
    self.MMWR_year = mmwr.mmwr_year
  end

  def set_event_onset_date
    self.event_onset_date = Date.today
  end

  # DEBT: Replace these one by one as we switch to the multi-model process used by lab results
  def save_associations
    participations << @active_patient unless @active_patient.nil?
    disease_events << @disease unless Utilities::model_empty?(@disease)
    participations << @active_jurisdiction unless (@active_jurisdiction.nil? or @active_jurisdiction.secondary_entity_id.blank?)
    participations << @active_reporting_agency unless (@active_reporting_agency.nil? or (@active_reporting_agency.secondary_entity_id.blank? and @active_reporting_agency.active_secondary_entity.place.name.blank?))
    participations << @active_reporter unless (@active_reporter.nil? or (@active_reporter.active_secondary_entity.person.last_name.blank? and @active_reporter.active_secondary_entity.person.first_name.blank?))
  end

  def save_multiples
    labs.each do |lab|
      if lab.lab_results.length == 0
        lab.destroy
        next
      end
      lab.save(false)
      lab.lab_results.each do |lab_result|
        lab_result.save(false)
      end
    end

    hospitalized_health_facilities.each do |hospital|
      hospital.save(false)
      hospital.hospitals_participation.save(false) unless hospital.hospitals_participation.nil?
    end

    diagnosing_health_facilities.each do |diagnostic|
      diagnostic.save(false)
    end

    contacts.each do |contact|
      contact.secondary_entity.person_temp.save(false)
    end

    active_patient.save(false)
    active_patient.active_primary_entity.save(false)

    active_patient.active_primary_entity.entities_locations.each do |el|
      el.save(false)           
      el.location.save(false)
      el.location.telephones.each {|t| t.save(false) unless t.frozen?}
    end
  end

end
