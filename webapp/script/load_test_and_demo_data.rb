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

county_codes = YAML::load_file "#{RAILS_ROOT}/db/defaults/counties.yml"

# Can't simply delete all and insert as the delete may trigger a FK constraint
Code.transaction do
  county_codes.each do |code|

    c = ExternalCode.find_or_initialize_by_code_name_and_the_code(:code_name => code['code_name'],
      :the_code => code['the_code'],
      :code_description => code['code_description'],
      :sort_order => code['sort_order'])

    c.attributes = code unless c.new_record?
    c.save!
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

# Users are represented as an array of hashes
users = YAML::load_file "#{RAILS_ROOT}/db/defaults/users.yml"

User.load_default_users(users)

# Create a default superuser
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
  unassigned =Place.unassigned_jurisdiction.entity_id

  data_entry_tech_role = Role.find_by_role_name("Data Entry Technician").id
  surveillance_mgr_role = Role.find_by_role_name("Surveillance Manager").id
  investigator_role = Role.find_by_role_name("Investigator").id
  lhd_manager_role = Role.find_by_role_name("LHD Manager").id
  state_manager_role = Role.find_by_role_name("State Manager").id

  data_entry_tech.update_attributes( { :role_membership_attributes => [{ :role_id => data_entry_tech_role, :jurisdiction_id => bear_river },
        { :role_id => data_entry_tech_role, :jurisdiction_id => unassigned }] } )

  surveillance_mgr.update_attributes( { :role_membership_attributes => [{ :role_id => surveillance_mgr_role, :jurisdiction_id => bear_river },
        { :role_id => surveillance_mgr_role, :jurisdiction_id => unassigned }] } )

  investigator.update_attributes( { :role_membership_attributes => [{ :role_id => investigator_role, :jurisdiction_id => bear_river },
        { :role_id => investigator_role, :jurisdiction_id => unassigned }] } )

  lhd_manager.update_attributes( { :role_membership_attributes => [{ :role_id => lhd_manager_role, :jurisdiction_id => bear_river }] } )

  state_manager.update_attributes( { :role_membership_attributes => [{ :role_id => state_manager_role, :jurisdiction_id => bear_river }] } )

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

# DEBT: for now, creating test translations will happen here, rather then the plugin
the_magic = proc do |code|
  code_id = code.class.name.underscore.gsub('translation', 'id')
  copy = code.class.find(:first, :conditions => {:locale => 'test', code_id => code.try(code_id)})
  copy = code.clone unless copy
  copy.locale = 'test'
  copy.code_description = "x#{copy.code_description}"
  copy.save!
end
CodeTranslation.transaction do
  CodeTranslation.all.each(&the_magic)
end
ExternalCodeTranslation.transaction do
  ExternalCodeTranslation.all.each(&the_magic)
end
