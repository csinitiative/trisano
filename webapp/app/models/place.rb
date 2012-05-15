# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class Place < ActiveRecord::Base
  belongs_to :entity
  has_and_belongs_to_many :place_types,
    :foreign_key => 'place_id',
    :class_name => 'Code',
    :join_table => 'places_types',
    :association_foreign_key => 'type_id',
    :order => 'code_description'

  validates_presence_of :name
  validates_each :name, :if => :is_unassigned_jurisdiction? do |record, attr, value|
    if unassigned = self.unassigned_jurisdiction
      record.errors.add(attr, :unassigned_is_special) unless unassigned == record
    end
  end
  validates_presence_of :short_name, :if => :is_a_jurisdiction?

  before_update :set_jurisdiction_place_type, :if => :is_a_jurisdiction?

  validate :not_modifying_special_jurisdiction_names, :if => :is_a_jurisdiction?, :on => :update


  named_scope :active, {
    :include => :entity,
    :conditions => {:entities => {:deleted_at => nil}}
  }

  named_scope :types, lambda { |types|
    { :include => :place_types,
      :conditions => { :codes => {:code_name => 'placetype', :the_code => types} },
    }
  }

  named_scope :diagnostic_facilities, lambda { |name|
    { :conditions => ["places.name ILIKE ? AND codes.code_name = 'placetype' AND codes.the_code IN (?) AND entities.deleted_at IS NULL", name + '%', Place.diagnostic_type_codes],
      :include => [:place_types, :entity],
      :order => 'LOWER(TRIM(places.name)) ASC'
    }
  }

  named_scope :starts_with, lambda { |name|
    { :conditions => [ "name ~* ?", "^#{name}" ] }
  }

  named_scope :reporting_agencies_by_name, lambda { |name|
    { :conditions => ["places.name ILIKE ? AND codes.code_name = 'placetype' AND codes.the_code IN (?) AND entities.deleted_at IS NULL", name + '%', Place.agency_type_codes],
      :include => [:place_types, :entity],
      :order => 'LOWER(TRIM(places.name)) ASC'
    }
  }

  class << self

    # TODO:  Does not yet take into account multiple edits of a single hospital.  Can probably be optimized.
    def hospitals(unique=false)
      if unique
        select = "DISTINCT ON (name) places.*"
        self.all_by_place_code('H', select)
      else
        self.all_by_place_code('H')
      end
    end

    def jurisdictions
      jurisdictions = self.all_by_place_code('J')
      pull_unassigned_and_put_it_on_top(jurisdictions)
    end

    def jurisdiction_by_name(name)
      all_by_name_and_types(name, 'J').first
    end

    def labs_by_name(name)
      all_by_name_and_types(name, 'L')
    end

    def all_by_name_and_types(name, type_codes, short_name=false)
      type_codes = [ type_codes ] unless type_codes.is_a?(Array)
      self.all(:include => [:place_types, :entity],
        :conditions => [ "LOWER(places.#{short_name ? 'short_name' : 'name'}) = ? AND codes.the_code IN (?) AND codes.code_name = 'placetype' AND entities.deleted_at IS NULL", name.downcase, type_codes ],
        :order => "LOWER(TRIM(name))")
    end

    def jurisdictions_for_privilege_by_user_id(user_id, privilege)
      query = "
        SELECT
                places.id, places.entity_id, places.name, places.short_name
        FROM
                users,
                role_memberships,
                privileges_roles,
                privileges,
                entities,
                places
        WHERE
                users.id = role_memberships.user_id
        AND
                privileges.id = privileges_roles.privilege_id
        AND
                role_memberships.role_id = privileges_roles.role_id
        AND
                role_memberships.jurisdiction_id = entities.id
        AND
                places.entity_id = entities.id
        AND
                users.id = '#{user_id}'
        AND
                privileges.priv_name = '#{privilege.to_s}'
        ORDER BY
                places.name"

      jurisdictions = find_by_sql(query)
      pull_unassigned_and_put_it_on_top(jurisdictions)
    end

    def hospitalization_type_codes
      %w(H)
    end

    def lab_type_codes
      %w(L)
    end

    def agency_type_codes
      %w(H L C O S DC CF LCF PUB OOS)
    end

    def diagnostic_type_codes
      %w(H L C O S CF PUB OOS)
    end

    def epi_type_codes
      %w(S P FE DC RA E CF LCF GLE)
    end

    # Includes a unique array of all of the above, which should not include
    # jurisdictions.
    def exposed_type_codes
      (agency_type_codes + diagnostic_type_codes + epi_type_codes).uniq
    end

    def agency_types
      place_types(agency_type_codes)
    end

    def diagnostic_types
      place_types(diagnostic_type_codes)
    end

    def epi_types
      place_types(epi_type_codes)
    end

    def exposed_types
      place_types(exposed_type_codes)
    end

    def place_types(type_codes)
      Code.active.find(:all,
        :conditions => ['code_name = ? AND the_code IN (?)', 'placetype', type_codes])
    end

    def all_by_place_code(code, select=nil)
      if select
        self.all(
          :select => select,
          :joins => [:place_types, :entity],
          :conditions => "codes.the_code = '#{code}' AND codes.code_name = 'placetype' AND entities.deleted_at IS NULL",
          :order => 'name, places.id'
        )
      else
        self.all(
          :include => [:place_types, :entity],
          :conditions => "codes.the_code = '#{code}' AND codes.code_name = 'placetype' AND entities.deleted_at IS NULL",
          :order => 'name, places.id'
        )
      end
    end

    def unassigned_jurisdiction
      self.first({
          :joins => [:place_types, :entity],
          :conditions => ["name = ? AND codes.the_code = ? AND codes.code_name = ?",
            "Unassigned",
            Code.jurisdiction_place_type.the_code,
            "placetype"]
        })
    end

    def unassigned_jurisdiction_entity_id
      unassigned_jurisdiction.try(:entity_id)
    end

    def pull_unassigned_and_put_it_on_top(jurisdictions)
      unassigned = jurisdictions.find { |jurisdiction| jurisdiction.read_attribute(:name) == "Unassigned" }
      jurisdictions.unshift( jurisdictions.delete( unassigned ) ) unless unassigned.nil?
      jurisdictions
    end
  end

  def xml_fields
    [:name, [:place_type_ids, {:rel => :place_type}]]
  end

  def place_descriptions
    place_types.sort_by(&:sort_order).collect { |pt| pt.code_description }
  end

  def formatted_place_descriptions
    place_descriptions.to_sentence
  end

  # The unassigned jurisdiction is the only place with a translated name, so
  # we have overriden the name getter to go to the locale configs for the
  # correct translation to display.
  def name
    if read_attribute(:name) == 'Unassigned'
      I18n.translate('unassigned_jurisdiction_name')
    else
      read_attribute(:name)
    end
  end

  def short_name
    if is_unassigned_jurisdiction?
      I18n.translate('unassigned_jurisdiction_name')
    else
      read_attribute(:short_name)
    end
  end

  def is_unassigned_jurisdiction?
    is_a_jurisdiction? && self.read_attribute(:name) == "Unassigned"
  end
  alias unassigned_jurisdiction? is_unassigned_jurisdiction?

  def is_a_jurisdiction?
    self.place_type_ids.include?(Code.jurisdiction_place_type_id)
  end

  def set_jurisdiction_place_type
  # Once a Place is created as a Jurisdiction
  # it's place type will always be set to Jurisdiction
    self.place_types = [Code.find(Code.jurisdiction_place_type_id)]
  end

  def not_modifying_special_jurisdiction_names
    special_jurisdiction_names = ["Out of State", "Unassigned"]
    # Uses the ActiveRecord::Dirty to determine if user is modifying the name of a special jurisdiction
    self.errors.add(:base, "Cannot modify the name of this Jurisdiction.") if self.name_changed? && special_jurisdiction_names.include?(self.name_was)
  end

end
