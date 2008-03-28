require 'chronic'

class Place < ActiveRecord::Base
  belongs_to :place_type, :class_name => 'Code'
  belongs_to :entity 

  # TODO:  Does not yet take into account multiple edits of a single hospital.  Can probably be optimized.
  def self.hospitals
    find_all_by_place_type_id(Code.find_by_code_name_and_the_code('placetype', 'H').id, :order => 'name')
  end

  def is_hospital?
    place_type_id == Code.find_by_code_name_and_code_description('placetype', 'Hospital').id
  end

  def self.jurisdictions
    find_all_by_place_type_id(Code.find_by_code_name_and_code_description('placetype', 'Jurisdiction').id, :order => 'name')
  end

  def self.jurisdictions_for_privilege_by_user_id(user_id, privilege)
    query = "
      SELECT
              places.entity_id, places.name
      FROM
              users,
              entitlements,
              privileges,
              entities, 
              places
      WHERE
              users.id = entitlements.user_id
      AND
              privileges.id = entitlements.privilege_id
      AND
              entitlements.jurisdiction_id = entities.id
      AND
              places.entity_id = entities.id
      AND
              users.id = '#{user_id}'
      AND
              privileges.priv_name = '#{privilege.to_s}' 
      ORDER BY
              places.name"

    find_by_sql(query)
  end
end
