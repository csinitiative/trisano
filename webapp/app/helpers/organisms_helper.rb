module OrganismsHelper

  def organism_tools(organism)
    haml_tag :div, :class => 'tools', :style => "position: absolute; right: 15px;" do
      haml_concat link_to_unless_current('Show', organism)
      haml_concat " | "
      haml_concat link_to_unless_current('Edit', edit_organism_path(organism))
    end
  end

end
