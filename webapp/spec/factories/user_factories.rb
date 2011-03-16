Factory.define :user do |u|
  u.uid { Factory.next(:uid) }
  u.user_name { Factory.next(:user_name) }
  u.status 'active'
  u.after_build { |user| User.current_user = user }
end

Factory.define :privileged_user, :parent => :user do |u|
  u.after_create  do |user|
    Factory(:privileged_role_membership, :user => user)
    user.reload
  end
end

Factory.define :privileged_role, :class => 'role' do |sr|
  sr.role_name "Privileged User"
end

Factory.define :privileged_role_membership, :class => 'role_membership' do |rm|
  rm.association :role, :factory => :privileged_role

  def rm.default_jurisdiction
    # Note: The exists? call is required to allow re-use between example groups.
    if @default_jurisdiction && PlaceEntity.exists?(@default_jurisdiction.id)
      @default_jurisdiction
    else
      @default_jurisdiction = create_jurisdiction_entity
    end
  end

  rm.jurisdiction { |r| rm.default_jurisdiction }
end

Factory.define :role_membership do |rm|
end

Factory.define :role do |r|
  r.role_name { Factory.next(:role_name) }
end

Factory.define :privilege do |p|
  p.priv_name { Factory.next(:priv_name) }
end


#
# Sequences
#
Factory.sequence :user_name do |n|
  "#{Faker::Name.first_name} #{n}"
end

Factory.sequence :uid do |n|
  "#{n}"
end

Factory.sequence :role_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

Factory.sequence :priv_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

#
# Helpers
#
def add_privileges_for(user, privs = nil)
  if privs
    privs.each do |priv|
      p = Privilege.find_by_priv_name(priv)
      PrivilegesRole.create(:role => user.roles.first, :jurisdiction => user.role_memberships.first.jurisdiction, :privilege => p)
    end

  else
    Privilege.all.each do |p|
      PrivilegesRole.create(:role => user.roles.first, :jurisdiction => user.role_memberships.first.jurisdiction, :privilege => p)
    end
  end

  return user
end

def remove_privileges_for(user, privs = nil)
  if privs
    privs.each do |priv|
      p = Privilege.find_by_priv_name(priv)
      user.roles.first.privileges_roles.find_by_privilege_id(p).destroy
    end

  else
    user.roles.first.privileges_roles.each { |pr| pr.destroy }
  end

  return user
end

# for when your place_entity *really* needs to be a jurisdiction
def create_jurisdiction_entity(options = {})
  place_attributes = options.delete(:place_attributes) || {}
  returning(Factory(:place_entity, options)) do |entity|
    place_type = Code.jurisdiction_place_type(true) || Factory.create(:place_type, :the_code => 'J')
    if place_type
      entity.place.place_type_ids = [place_type.id]
      entity.place.short_name = entity.place.name
      entity.place.update_attributes!(place_attributes)
    end
  end
end

def login_as_super_user
  @current_user = Factory(:user)
  create_super_role
  Role.all.each do |r|
    Place.jurisdictions.each do |j|
      attr = {:jurisdiction_id => j.entity_id, :role => r}
      @current_user.role_memberships.build(attr).save!
    end
  end
end

def create_super_role
  @super_role = Factory(:privileged_role)
  Privilege.all.each { |p| add_privilege_to_role_in_all_jurisdictions(p, @super_role) }
end

def add_privilege_to_role_in_all_jurisdictions(privilege, role)
  clean_up_jurisdictions
  create_jurisdiction_entity if Place.jurisdictions.empty?
  Place.jurisdictions.each do |j|
    attr = {:jurisdiction_id => j.entity_id, :privilege => privilege}
    role.privileges_roles.build(attr).save!
  end
end

def clean_up_jurisdictions
  Place.jurisdictions.each do |jurisdiction|
    jurisdiction.delete if Entity.find_by_id(jurisdiction.entity_id).nil?
  end
end

def logout
  User.current_user = nil
end

def create_role_with_privileges!(role_name, *privileges)
  role = create_role!(role_name)
  privileges.each do |priv_name|
    privilege = create_privilege!(priv_name.to_s)
    add_privilege_to_role_in_all_jurisdictions(privilege, role)
  end
  role
end

def create_privilege!(priv_name)
  priv = Privilege.first(:conditions => { :priv_name => priv_name.to_s })
  unless priv
    priv = Factory.create(:privilege, :priv_name => priv_name.to_s)
  end
  priv
end

def create_role!(role_name)
  role = Role.first(:conditions => ['lower(role_name) = ?', role_name.downcase])
  unless role
    role = Factory.create(:role, :role_name => role_name)
  end
  raise "Role '#{role_name}' couldn't be found" unless role
  role
end

def create_user_in_role!(role_name, user_name)
  name = user_name.split(' ')
  user = Factory.create(:user, {
                          :first_name => name.first,
                          :last_name => name.last,
                          :uid => name.join('_')
                        })
  role = create_role!(role_name)
  Place.jurisdictions.each do |j|
    RoleMembership.create!({ :jurisdiction_id => j.entity_id,
                             :user_id => user.id,
                             :role_id => role.id })
  end
  yield user if block_given?
  user
end
