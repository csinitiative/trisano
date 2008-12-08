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

class Person < ActiveRecord::Base
  # acts_as_auditable
  belongs_to :birth_gender, :class_name => 'ExternalCode'
  belongs_to :ethnicity, :class_name => 'ExternalCode'
  belongs_to :primary_language, :class_name => 'ExternalCode'
  belongs_to :disposition, :class_name => 'ExternalCode'
  belongs_to :entity 

  validates_presence_of :last_name
  validates_date :birth_date, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true
  validates_length_of :last_name, :maximum => 25, :allow_blank => true
  validates_length_of :first_name, :maximum => 25, :allow_blank => true
  validates_length_of :middle_name, :maximum => 25, :allow_blank => true

  before_save :generate_soundex_codes
  
  # Debt? Just getting this done fast after dives on options took a long time.
  # Should method this be in entity.rb? Is there a better way to handle custom
  # SQL? What about this?
  # http://www.edwardthomson.com/blog/2007/02/complex_sql_queries_with_rails.html
  def self.find_by_ts(*args)
    options = args.extract_options!
    where_clause = ""
    order_by_clause = ""
    fulltext_terms = []
    issue_query = false
    
    # Debt: The UI shows the user a format to use. Something a bit more robust
    # could be in place.    
    if !options[:birth_date].blank?
      american_date = '%m/%d/%Y'
      date = Date.strptime(options[:birth_date], american_date).to_s
      issue_query = true
      where_clause += "birth_date = '#{date}'"
      order_by_clause += "last_name, first_name ASC;" 
    end
    
    # Some more debt here. The sql_term building is duplicated in Event. Where
    # do you factor out code common to models? Also, it may be that we don't need
    # two different search avenues (CMR and People).
    if !options[:fulltext_terms].blank?
      
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
      
      where_clause += " AND " if !where_clause.empty?
      where_clause += "vector @@ to_tsquery('#{sql_terms}')"
      order_by_clause = " ts_rank(vector, '#{sql_terms}') DESC, last_name, first_name ASC;"
    end
    
    query = "SELECT people.entity_id, first_name, middle_name, last_name, birth_date, c.code_description as gender, co.code_description as county
                  FROM (SELECT DISTINCT ON(entity_id) * FROM people ORDER BY entity_id, created_at DESC) people
                    LEFT OUTER JOIN external_codes c on c.id = people.birth_gender_id
                    LEFT OUTER JOIN (select distinct on (entity_id) * from entities_locations order by entity_id, created_at desc) el on el.entity_id = people.entity_id
                    LEFT OUTER JOIN locations l on l.id = el.location_id
                    LEFT OUTER JOIN (select distinct on (location_id) * from addresses order by location_id, created_at desc) a on a.location_id = l.id
                    LEFT OUTER JOIN external_codes co on co.id = a.county_id
                  WHERE #{where_clause} ORDER BY #{order_by_clause}"
    
    find_by_sql(query) if issue_query
  end

  def full_name
    "#{self.first_name} #{self.last_name}".strip
  end

  def telephone
    self.entity.telephone
  end

  def address
    self.entity.address
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

  def disposition_description
    disposition.code_description unless disposition.blank?
  end

  # Builds a presentable description of the person's race.
  def race_description
    unless entity.blank? || entity.races.empty?
      races = entity.races.collect {|race| race.code_description}
      description = races[0...-1] * ', '
      description += ' and ' if races.size > 1
      return description + races[-1]
    end  
  end

  protected
  def validate
    if !date_of_death.blank? && !birth_date.blank?
      errors.add(:date_of_death, "The date of death precedes birth date") if date_of_death.to_date < birth_date.to_date
    end
  end
  
  # Soundex codes are generated at save time.
  # Debt: Strip out apostrophes and hyphens? We'd have to do the same on the 
  # query side. Perhaps abstract Soundex generation out somewhere.
  def generate_soundex_codes
    if !first_name.blank?
      self.first_name_soundex = Text::Soundex.soundex(first_name)
    end
    
    self.last_name_soundex = Text::Soundex.soundex(last_name)
  end
  
end
