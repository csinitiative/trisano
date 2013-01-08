# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class Person < ActiveRecord::Base
  include FulltextSearch

  belongs_to :person_entity, :foreign_key => 'entity_id'
  has_many   :participations, :foreign_key => 'secondary_entity_id', :primary_key => 'entity_id' 

  belongs_to :birth_gender, :class_name => 'ExternalCode'
  belongs_to :ethnicity, :class_name => 'ExternalCode'
  belongs_to :primary_language, :class_name => 'ExternalCode'

  validates_presence_of :last_name
  validates_date :birth_date, :allow_blank => true,
                              :on_or_before => lambda { Date.today } # Birth date cannot be in the future.

  validates_date :date_of_death,  :allow_blank => true,
                                  :on_or_before => lambda { Date.today }, # Date of death cannot be in the future.
                                  :on_or_after => :birth_date # Date of death cannot be before birth_date.

  validates_length_of :last_name, :maximum => 25, :allow_blank => true
  validates_length_of :first_name, :maximum => 25, :allow_blank => true
  validates_length_of :middle_name, :maximum => 25, :allow_blank => true

  named_scope :active, 
    :include => :person_entity,
    :conditions => "entities.deleted_at IS NULL"

  named_scope :clinicians,
     :conditions => "person_type = 'clinician'",
     :order => "last_name, first_name"

  named_scope :reporters,
    :include => :participations,
    :conditions => "participations.type = 'Reporter'",
    :order => 'last_name, first_name'


  def xml_fields
    [:birth_date,
     :first_name,
     :middle_name,
     :last_name,
     :date_of_death,
     [:birth_gender_id, {:rel => :gender}],
     [:primary_language_id, {:rel => :language}],
     [:ethnicity_id, {:rel => :ethnicity}]]
  end

  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end

  def last_comma_first
    ("#{self.last_name}"  << (self.first_name.blank? ? "" : ", #{self.first_name}")).strip
  end

  def last_comma_first_middle
    result = "#{self.first_name} #{self.middle_name}".strip
    result = ", " + result unless result.blank?

    self.last_name + result
  end

  def self.last_comma_first_middle(person)
    result = "#{person['first_name']} #{person['middle_name']}".strip
    result = ", " + result unless result.blank?

    person['last_name'] + result
  end

  def primary_phone
    self.person_entity.primary_phone
  end

  def age
    (Date.today - self.birth_date.to_date).to_i / 365 unless self.birth_date.blank?
  end

  def birth_gender_description
    birth_gender.code_description unless birth_gender.blank?
  end

  def ethnicity_description
    ethnicity.code_description unless ethnicity.blank?
  end

  def primary_language_description
    primary_language.code_description unless primary_language.blank?
  end

  # Builds a presentable description of the person's race.
  def race_description
    unless person_entity.blank? || person_entity.races.empty?
      races = person_entity.races.collect {|race| race.code_description}
      description = races[0...-1] * ', '
      description += ' and ' if races.size > 1
      return description + races[-1]
    end
  end

  def dead?
    !person_entity.human_events.detect do |evt|
      unless evt.disease_event.nil? || evt.disease_event.died.nil?
        evt.disease_event.died.yes?
      end
    end.nil?
  end

  def delete
    person_entity.try(:update_attributes, :deleted_at => DateTime.now)
  end

  class << self
    def create_with_entity!(options = {})
      place_entity = PersonEntity.create!(:person_attributes => options)
      place_entity.place
    end

    # Defaults to not showing deleted people. Override by providing the option:
    #   :show_deleted => true
    def find_all_for_filtered_view(options = {})
      options[:fulltext_terms] ||= "#{options[:last_name]} #{options[:first_name]}".strip
      options.delete(:fulltext_terms) if options[:fulltext_terms].blank? || options[:use_starts_with_search]

      row_count = Person.count_by_sql(construct_count_sql(options))
      find_options = {
        :page          => options[:page],
        :total_entries => row_count
      }
      find_options[:per_page] = options[:per_page] if options[:per_page].to_i > 0

      Person.paginate_by_sql(construct_select_sql(options), find_options)
    rescue Exception => ex
      logger.error ex
      raise ex
    end

    def construct_select_sql(options)
      returning [] do |sql|
        sql << "SELECT "
        sql << search_select_fields(options).join(",\n")
        sql << "FROM people"
        sql << people_search_joins(options).join("\n")
        unless (where = people_search_conditions(options)).blank?
          sql << "WHERE"
          sql << where
        end
        sql << "ORDER BY"
        sql << people_search_order(options)
      end.compact.join("\n")
    end

    def search_select_fields(options)
      returning [] do |fields|
        unless options[:person_type].blank?
          fields << "DISTINCT(entities.id)"
          fields << "search_results.rank AS rank" if include_fulltext?(options)
        end
        fields << "people.*"
        fields << "addresses.street_number"
        fields << "addresses.street_name"
        fields << "addresses.unit_number"
        fields << "addresses.city"
        fields << "addresses.state_id"
        fields << "addresses.postal_code"
        fields << "states.code_description AS state_name"
      end
    end

    def construct_count_sql(options)
      returning [] do |sql|
        sql << "SELECT COUNT(*) FROM people"
        sql << people_search_joins(options).join("\n")
        unless (where = people_search_conditions(options)).blank?
          sql << "WHERE"
          sql << where
        end
      end.compact.join("\n")
    end

    def people_search_joins(options)
      returning [] do |joins|
        unless options[:show_deleted]
          joins << "INNER JOIN entities on people.entity_id = entities.id"
        end
        unless options[:person_type].blank?
          joins << "LEFT JOIN participations ON people.entity_id = participations.#{options[:person_type] == 'InterestedParty' ? 'primary_entity_id' : 'secondary_entity_id'}"
        end
        joins << "LEFT JOIN addresses ON people.entity_id = addresses.entity_id AND addresses.event_id IS NULL"
        joins << "LEFT JOIN external_codes AS states ON addresses.state_id = states.id"
        joins << fulltext_join(options) if include_fulltext?(options)
      end.compact
    end

    def people_search_conditions(options)
      returning [] do |conditions|
        conditions << name_conditions(options)
        conditions << birth_date_conditions(options)
        conditions << type_conditions(options)
        conditions << deleted_conditions(options)
        conditions << excluding_conditions(options)
      end.flatten.compact.join("\nAND\n")
    end

    def people_search_order(options)
      unless options[:order_by].blank?
        options[:order_by].sub!(/^person_name\s+(\w+)$/, 'last_name \1, first_name \1, middle_name \1')
        options[:order_by].sub!(/^address\s+(\w+)$/, 'addresses.street_number \1, addresses.street_name \1' +
                                ', addresses.unit_number \1, addresses.city \1, state_name \1' +
                                ', addresses.postal_code \1')
        sanitize_sql(options[:order_by])
      else
        options[:use_starts_with_search].blank? ? (fulltext_order(options) || "last_name, first_name ASC") : "last_name, first_name ASC"
      end
    end

    def excluding_conditions(options)
      if excluding = options[:excluding]
        c = [ 'people.entity_id NOT IN (?)', [excluding].flatten ]
        sanitize_sql_for_conditions(c)
      end
    end

    def name_conditions(options)
      if options[:use_starts_with_search]
        returning([]) do |sw|
          sw << ["last_name ILIKE ?", options[:last_name].strip + '%']     unless options[:last_name].blank?
          sw << ["first_name ILIKE ?", options[:first_name].strip + '%']   unless options[:first_name].blank?
          sw << ["middle_name ILIKE ?", options[:middle_name].strip + '%'] unless options[:middle_name].blank?
        end.map{|sw| sanitize_sql_for_conditions(sw)}.join("\nAND\n")
      end
    end

    def birth_date_conditions(options)
      unless options[:birth_date].blank?
        sanitize_sql_for_conditions(["(birth_date IS NULL OR birth_date = ?)",options[:birth_date]])
      end
    end

    def type_conditions(options)
      unless options[:person_type].blank?
        sanitize_sql_for_conditions(["participations.type = ?", options[:person_type]])
      end
    end

    def deleted_conditions(options)
      unless options[:show_deleted]
        "entities.deleted_at IS NULL"
      end
    end

    def include_fulltext?(options)
      options[:use_starts_with_search].blank? && options[:fulltext_terms]
    end

    def search_type_options
      [[nil, nil]] + valid_search_types
    end

    def valid_search_types
      [
          ["Interested party (patient, contact)", "InterestedParty"],
          ["Clinician", "Clinician"],
          ["Reporter", "Reporter"]
      ]
    end
  end

end
