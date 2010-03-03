module OrganismsHelper

  def organism_tools(organism)
    haml_tag :div, :class => 'tools' do
      haml_concat link_to_unless_current(t('show'), organism)
      haml_concat "&nbsp;|&nbsp;"
      haml_concat link_to_unless_current(t('edit'), edit_organism_path(organism))
    end
  end

  def diseases_organism_options
    Disease.all(:order => 'disease_name').collect do |d|
      [d.disease_name, d.id]
    end
  end
end
