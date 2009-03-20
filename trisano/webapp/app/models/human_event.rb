# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

class HumanEvent < Event
  include Export::Cdc::HumanEvent  

  validates_length_of :parent_guardian, :maximum => 255, :allow_blank => true

  validates_numericality_of :age_at_onset,
    :allow_nil => true,
    :greater_than_or_equal_to => 0,
    :only_integer => true,
    :message => 'is negative. This is usually caused by an incorrect onset date or birth date.'

  before_validation_on_create :set_age_at_onset
  before_validation_on_update :set_age_at_onset

  has_one :interested_party, :foreign_key => "event_id"

  has_many :labs,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :hospitalization_facilities,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :diagnostic_facilities,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :clinicians,
    :foreign_key => "event_id",
    :order => 'created_at ASC',
    :dependent => :destroy

  belongs_to :participations_contact
  belongs_to :participations_encounter

  accepts_nested_attributes_for :interested_party
  accepts_nested_attributes_for :hospitalization_facilities, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs["secondary_entity_id"].blank? && attrs["hospitals_participation_attributes"].all? { |k, v| v.blank? } } 
  accepts_nested_attributes_for :clinicians, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs.has_key?("person_entity_attributes") && attrs["person_entity_attributes"]["person_attributes"].all? { |k, v| if v == 'clinician' then true else v.blank? end } }
  accepts_nested_attributes_for :diagnostic_facilities, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs.has_key?("place_entity_attributes") && attrs["place_entity_attributes"]["place_attributes"].all? { |k, v| v.blank? } } 
  accepts_nested_attributes_for :labs, 
    :allow_destroy => true, 
    :reject_if => proc { |attrs| rewrite_attrs(attrs) }
  accepts_nested_attributes_for :participations_contact, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :participations_encounter, :reject_if => proc { |attrs| attrs.all? { |k, v| ((k == "user_id") ||  (k == "encounter_location_type")) ? true : v.blank? } }

  class << self
    def rewrite_attrs(attrs)
      entity_attrs = attrs["place_entity_attributes"]
      lab_attrs = entity_attrs["place_attributes"]
      return true if (lab_attrs.all? { |k, v| v.blank? } && attrs["lab_results_attributes"].all? { |k, v| v.all? { |k, v| v.blank? } })

      # If there's a lab with the same name already in the database, use that instead.
      lab_type_id = Code.lab_place_type_id
      existing_lab = Place.find_by_name_and_place_type_id(lab_attrs["name"], lab_type_id)
      if existing_lab
        attrs["secondary_entity_id"] = existing_lab.entity_id
        attrs.delete("place_entity_attributes")
      else
        lab_attrs["place_type_id"] = lab_type_id
      end

      return false
    end

    def new_event_from_patient(patient_entity)
      event = MorbidityEvent.new
      event.build_interested_party(:primary_entity_id => patient_entity.id)
      event.build_jurisdiction
      event.jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.jurisdiction_by_name("Unassigned")).entity
      event.event_status = 'NEW'
      entity_address = patient_entity.addresses.find(:first, :conditions => 'event_id IS NOT NULL', :order => 'created_at DESC')
      event.address = entity_address ? entity_address.clone : nil
      event
    end

    def search_by_name(name)
      soundex_codes = []
      fulltext_terms = []
      raw_terms = name.split(" ")

      raw_terms.each do |word|
        soundex_codes << word.to_soundex.downcase unless word.to_soundex.nil?
        fulltext_terms << sanitize_sql(["%s", word]).sub(",", "").downcase
      end

      fulltext_terms << soundex_codes unless soundex_codes.empty?
      sql_terms = fulltext_terms.join(" | ")

      where_clause = "people.vector @@ to_tsquery('#{sql_terms}')"
      order_by_clause = " ts_rank(people.vector, to_tsquery('#{sql_terms}')) DESC, people.last_name, people.first_name, entities.id ASC;"

      options = { :include => [ { :interested_party => { :person_entity => :person } }, :disease_event ],
                  :conditions => where_clause,
                  :order => order_by_clause }

      # This may or may not be a Rails bug, but in order for HumanEvent to know that MorbidityEvent and ContactEvent are
      # its descendents, and thus generate the proper where clause, Rails needs to have 'seen' these classes at least
      # once, so do something innocuous in order to ensure this.
      MorbidityEvent.object_id; ContactEvent.object_id
      self.all(options)
    end

  end

  def lab_results
    @results ||= (
      results = []
      labs.each do |lab|
        lab.lab_results.each do |lab_result|
          results << lab_result
        end
      end
      results
    )
  end

  def definitive_lab_result
    # CDC calculations expect one lab result.  Choosing the most recent to be it
    return nil if lab_results.empty?
    self.lab_results.sort_by { |lab_result| lab_result.lab_test_date || Date.parse("01/01/0000") }.last
  end

  def set_primary_entity_on_secondary_participations
    self.participations.each do |participation|
      if participation.primary_entity_id.nil?
        participation.update_attribute('primary_entity_id', self.interested_party.person_entity.id)
      end
    end
  end

  def party
    @party ||= self.safe_call_chain(:interested_party, :person_entity, :person)
  end

  private

  def set_age_at_onset
    birthdate = safe_call_chain(:interested_party, :person_entity, :person, :birth_date)
    onset = onset_candidate_dates.compact.first
    self.age_info = AgeInfo.create_from_dates(birthdate, onset)    
  end

  def onset_candidate_dates
    dates = []
    dates << safe_call_chain(:disease_event, :disease_onset_date)
    dates << safe_call_chain(:disease_event, :date_diagnosed)
    collections = []
    test_dates = []
    self.labs.each do |l| 
      l.lab_results.collect{|r| collections << r.collection_date}
      l.lab_results.collect{|r| test_dates << r.lab_test_date}
    end
    dates << collections.compact.sort
    dates << test_dates.compact.sort
    dates << self.first_reported_PH_date
    dates << self.event_onset_date
    dates << self.created_at.to_date unless self.created_at.nil?
    dates.flatten
  end

end
