module UsersSpecHelper

  def add_privileges_for(user, privs = nil)
    if privs
      privs.each do |priv|
        p = Privilege.find_by_priv_name(priv.to_s)
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

  def create_unassigned_jurisdiction_entity
    create_jurisdiction_entity(:place_attributes => { :name => "Unassigned" })
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
      :uid => name.join('_').downcase
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

end
