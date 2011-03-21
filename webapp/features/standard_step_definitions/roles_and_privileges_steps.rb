Given /a role named "(.+)"/ do |role_name|
  @role = Role.find_by_role_name(role_name)
  @role = Role.create!(:role_name => role_name) unless @role
end

Given /the role "(.+)" has the following privileges:$/ do |role_name, table|
  @role = Role.find_by_role_name(role_name)
  privilege_names = table.raw.map(&:first)
  privilege_ids = Privilege.all.select { |priv| privilege_names.include? priv.name}.map(&:id)
  @role.privilege_ids = privilege_ids
  @role.save!
end
