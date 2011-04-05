Factory.define :user do |u|
  u.uid { Factory.next(:uid) }
  u.user_name { Factory.next(:user_name) }
  u.status 'active'
  if User.column_names.include?("crypted_password")
    u.password "changeme"
    u.password_confirmation { |u| u.password }
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
