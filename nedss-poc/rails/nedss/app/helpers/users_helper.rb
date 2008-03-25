module UsersHelper
  
  def add_role_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, :role_memberships, :partial => 'role', :object => RoleMembership.new
    end
  end
  
end
