module FormsHelper
  
    def show_groups_link(name, groups)
    link_to_function name do |page|
      page.replace_html :groups, :partial => 'groups', :object => groups
    end
  end
  
end
