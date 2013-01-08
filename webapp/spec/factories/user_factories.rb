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

Factory.define :user do |u|
  u.uid { Factory.next(:uid) }
  u.user_name { Factory.next(:user_name) }
  u.status 'active'
  if User.column_names.include?("crypted_password")
    if User.new.respond_to?(:password=)
      u.password "changeme"
      u.password_confirmation { |u| u.password }
    else
      u.crypted_password "random_pasword_hash"
      u.password_salt "random_password_salt"
      u.sequence(:persistence_token)  { |n|  "#{n}_random_token" }
      u.sequence(:single_access_token) { |n|  "#{n}_random_token" }
      u.sequence(:perishable_token) { |n|  "#{n}_random_token" }
    end
  end
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
  "#{Faker::Name.first_name}#{n}"
end

Factory.sequence :uid do |n|
  "#{Faker::Lorem.words(2)}#{n}"
end

Factory.sequence :role_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

Factory.sequence :priv_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end
