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
      entity.place.place_type_ids = [create_jurisdiction_place_type.id]
      entity.place.short_name = entity.place.name
      entity.place.update_attributes!(place_attributes)
    end
  end

  def create_unassigned_jurisdiction_entity
    begin
      place_entity = Place.unassigned_jurisdiction.entity
      raise if place_entity.nil?
      return place_entity
    rescue
      create_jurisdiction_entity(:place_attributes => { :name => "Unassigned" })
    end
  end

  def create_jurisdiction_place_type
    begin
      place_type_code = Code.jurisdiction_place_type(true)
      raise if place_type_code.nil?
      place_type_code
    rescue
      Factory.create(:place_type, :the_code => 'J')
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

  def mock_user
    @jurisdiction = Factory.build(:place_entity)
    @place = Factory.build(:place)

    @user = Factory.build(:user)
    User.stubs(:find_by_uid).returns(@user)
    User.stubs(:current_user).returns(@user)
    @user.stubs(:id).returns(1)
    @user.stubs(:uid).returns("default")
    @request.session[:user_id] = @user.uid if @request && !@request.session.nil?
    @user.stubs(:user_name).returns("default_user")
    @user.stubs(:first_name).returns("Johnny")
    @user.stubs(:last_name).returns("Johnson")
    @user.stubs(:given_name).returns("Johnny")
    @user.stubs(:initials).returns("JJ")
    @user.stubs(:generational_qualifer).returns("")
    @user.stubs(:is_admin?).returns(true)
    @user.stubs(:jurisdictions_for_privilege).returns([@place])
    @user.stubs(:is_entitled_to?).returns(true)
    @user.stubs(:event_view_settings).returns(nil)
    @user.stubs(:best_name).returns("Johnny Johnson")
    @user.stubs(:disabled?).returns(false)
    @user.stubs(:destroyed?).returns(false)
    @user.stubs(:can?).returns(true)

    @role_membership = Factory.build(:role_membership)
    @role = Factory.build(:role)

    @role.stubs(:role_name).returns("administrator")
    @role_membership.stubs(:role).returns(@role)
    @role_membership.stubs(:jurisdiction).returns(@jurisdiction)
    @role_membership.stubs(:role_id).returns("1")
    @role_membership.stubs(:jurisdiction_id).returns("75")
    @role_membership.stubs(:should_destroy).returns(0)
    @role_membership.stubs(:is_admin?).returns(true)
    @role_membership.stubs(:id=).returns(1)
    @jurisdiction.stubs(:places).returns([@place])
    @jurisdiction.stubs(:place).returns(@place)
    @place.stubs(:name).returns("Southeastern District")
    @place.stubs(:entity_id).returns("1")

    @user.stubs(:role_memberships).returns([@role_membership])
    @user.stubs(:admin_jurisdiction_ids).returns([75])
    @user.stubs(:is_entitled_to_in?).returns(true)
    @user.stubs(:new_record?).returns(false)

    @user
  end

  def create_user
    @user = Factory(:user)
    User.stubs(:find_by_uid).returns(@user)
    User.stubs(:current_user).returns(@user)
    @request.session[:user_id] = @user.uid if @request && !@request.session.nil?
    @user
  end
    
end
