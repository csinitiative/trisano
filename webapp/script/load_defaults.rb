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

# Hospitals are represented as an array of strings

hospitals = YAML::load_file "#{RAILS_ROOT}/db/defaults/hospitals.yml"
hospital_type = Code.find_by_code_name_and_the_code("placetype", "H")
Entity.transaction do
  hospitals.each do |hospital|
    h = PlaceEntity.find(:first,
      :include => { :place => :place_types },
      :select => "places.name",
      :conditions => ["codes.code_name = 'placetype' AND codes.the_code = 'H' AND places.name = ?", hospital])
    if h.nil?
      e = PlaceEntity.new
      e.build_place(:name => hospital)
      e.place.place_types << hospital_type
      e.save
    end
  end
end

# Jurisdictions are represented as an array of strings

jurisdictions = YAML::load_file "#{RAILS_ROOT}/db/defaults/jurisdictions.yml"
jurisdiction_type = Code.find_by_code_name_and_the_code("placetype", "J")
Entity.transaction do
  jurisdictions.each do |jurisdiction|
    j = PlaceEntity.find(:first,
      :include => { :place => :place_types },
      :select => "places.name",
      :conditions => ["codes.code_name = 'placetype' AND codes.the_code = 'J' AND places.name = ?", jurisdiction['name'] ])
    if j.nil?
      e = PlaceEntity.new
      e.build_place(:name => jurisdiction['name'], :short_name => jurisdiction['short_name'])
      e.place.place_types << jurisdiction_type
      e.save
    end
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

# Users are represented as an array of hashes
users = YAML::load_file "#{RAILS_ROOT}/db/defaults/users.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
User.transaction do
  users.each do |user|
    u = User.find_or_initialize_by_uid(:uid => user['uid'], :user_name => user['user_name'])
    u.attributes = user unless u.new_record?
    u.save!
  end
end

# Create a default superusers
RoleMembership.transaction do

  # Give these users all roles in all jurisdictions
  user = User.find_by_user_name('default_user')
  jurisdictions = PlaceEntity.find(:all,
    :include => { :place => :place_types },
    :conditions => "codes.code_name = 'placetype' AND codes.the_code = 'J'")

  roles = Role.find(:all)
  roles_for_default_users = []

  jurisdictions.each do |jurisdiction|
    roles.each do |role|
      roles_for_default_users << { :role_id => role.id, :jurisdiction_id => jurisdiction.id }
    end
  end

  user.update_attributes( { :role_membership_attributes => roles_for_default_users } )
end


# TODO: Create some ordinary users for testing purposes
User.transaction do

  data_entry_tech = User.find_by_user_name('data_entry_tech')
  surveillance_mgr = User.find_by_user_name('surveillance_mgr')
  investigator = User.find_by_user_name('investigator')
  lhd_manager = User.find_by_user_name('lhd_manager')
  state_manager = User.find_by_user_name('state_manager')

  bear_river = Place.find_by_name("Bear River Health Department").entity_id
  unassigned = Place.find_by_name("Unassigned").entity_id

  create_event = Privilege.find_by_priv_name("create_event").id
  view_event = Privilege.find_by_priv_name("view_event").id
  update_event = Privilege.find_by_priv_name("update_event").id
  route_event_to_any_lhd = Privilege.find_by_priv_name("route_event_to_any_lhd").id
  accept_event_for_lhd = Privilege.find_by_priv_name("accept_event_for_lhd").id
  route_event_to_investigator = Privilege.find_by_priv_name("route_event_to_investigator").id
  accept_event_for_investigation = Privilege.find_by_priv_name("accept_event_for_investigation").id
  investigate_event = Privilege.find_by_priv_name("investigate_event").id
  approve_event_at_lhd = Privilege.find_by_priv_name("approve_event_at_lhd").id
  approve_event_at_state = Privilege.find_by_priv_name("approve_event_at_state").id
  assign_task_to_user = Privilege.find_by_priv_name("assign_task_to_user").id
  add_form = Privilege.find_by_priv_name("add_form_to_event").id
  remove_form = Privilege.find_by_priv_name("remove_form_from_event").id

end

# Load county to jurisdiction relationships
ExternalCode.transaction do
  [{:county_name => 'Box Elder',  :health_district => 'Bear River'},
   {:county_name => 'Cache',      :health_district => 'Bear River'},
   {:county_name => 'Rich',       :health_district => 'Bear River'},
   {:county_name => 'Juab',       :health_district => 'Central Utah'},
   {:county_name => 'Millard',    :health_district => 'Central Utah'},
   {:county_name => 'Piute',      :health_district => 'Central Utah'},
   {:county_name => 'Sevier',     :health_district => 'Central Utah'},
   {:county_name => 'Sanpete',    :health_district => 'Central Utah'},
   {:county_name => 'Wayne',      :health_district => 'Central Utah'},
   {:county_name => 'Beaver',     :health_district => 'Southwest Utah'},
   {:county_name => 'Garfield',   :health_district => 'Southwest Utah'},
   {:county_name => 'Iron',       :health_district => 'Southwest Utah'},
   {:county_name => 'Kane',       :health_district => 'Southwest Utah'},
   {:county_name => 'Washington', :health_district => 'Southwest Utah'},
   {:county_name => 'Davis',      :health_district => 'Davis County'},
   {:county_name => 'Salt Lake',  :health_district => 'Salt Lake Valley'},
   {:county_name => 'Carbon',     :health_district => 'Southeastern Utah'},
   {:county_name => 'Emery',      :health_district => 'Southeastern Utah'},
   {:county_name => 'Grand',      :health_district => 'Southeastern Utah'},
   {:county_name => 'San Juan',   :health_district => 'Southeastern Utah'},
   {:county_name => 'Summit',     :health_district => 'Summit County'},
   {:county_name => 'Tooele',     :health_district => 'Tooele County'},
   {:county_name => 'Uintah',     :health_district => 'TriCounty'},
   {:county_name => 'Daggett',    :health_district => 'TriCounty'},
   {:county_name => 'Duchesne',   :health_district => 'TriCounty'},
   {:county_name => 'Utah',       :health_district => 'Utah County'},
   {:county_name => 'Weber',      :health_district => 'Weber-Morgan'},
   {:county_name => 'Morgan',     :health_district => 'Weber-Morgan'}
  ].each do |relationship|
    begin
      code = ExternalCode.find_by_code_name_and_code_description('county', relationship[:county_name])
      place = Place.find(:first, :include => :place_types, :conditions => "codes.the_code = 'J' AND short_name = '#{relationship[:health_district]}'")
      raise "Couldn't find jurisdiction #{relationship[:health_district]}" unless place
      code.jurisdiction = place
      code.save!
    rescue Exception => ex
      $stderr.puts("Failed to relate county #{relationship[:county_name]} to jurisdiction #{relationship[:health_district]}")
      raise
    end
  end
end
