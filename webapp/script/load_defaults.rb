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

puts "Loading defaults"

# Diseases are represented as an array of strings

diseases = YAML::load_file("#{RAILS_ROOT}/db/defaults/diseases.yml")
Disease.transaction do
  diseases.each do |disease|
    d = Disease.find_or_initialize_by_disease_name(
      :disease_name => disease['disease_name'],
      :cdc_code => disease['cdc_code']
    )
    d.active = true
    d.save! if d.new_record?
  end
end

# core fields
core_fields = YAML::load_file("#{RAILS_ROOT}/db/defaults/core_fields.yml")
CoreField.transaction do
  core_fields.each do |k, v|
    CoreField.create(v)
  end
end

# Privileges are represented as an array of strings

privileges = YAML::load_file "#{RAILS_ROOT}/db/defaults/privileges.yml"
Privilege.transaction do
  privileges.each do |privilege|
    p = Privilege.find_or_initialize_by_priv_name(:priv_name => privilege)
    p.save! if p.new_record?
  end
end

# Roles are represented as a hash. The keys are role names and the values are arrays of privs
roles = YAML::load_file "#{RAILS_ROOT}/db/defaults/roles.yml"

Role.transaction do
  # Note: Technically privileges have associated jurisdictions, we are ignoring that for the time being.
  roles.each_pair do |role_name, privs|
    r = Role.find_or_initialize_by_role_name(:role_name => role_name)
    r.privileges_roles.clear
    privs.each do |priv|
      p = Privilege.find_by_priv_name(priv)
      r.privileges_roles.build('privilege_id' => p.id)
    end
    r.save!
  end
end

# Create Unassigned jurisidiction

jurisdiction_type = Code.find_by_code_name_and_the_code("placetype", "J")
raise "Cannot continue without the jurisdiction place type loaded." if jurisdiction_type.nil?

admin_role = Role.find_by_role_name("Administrator")
raise "Cannot continue without the admin role loaded." if admin_role.nil?

unassigned_jurisdiction = PlaceEntity.new
unassigned_jurisdiction.build_place(:name => "Unassigned", :short_name => "Unassigned")
unassigned_jurisdiction.place.place_types << jurisdiction_type
unassigned_jurisdiction.save!
