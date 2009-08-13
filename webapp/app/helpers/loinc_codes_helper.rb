module LoincCodesHelper

  def loinc_code_tools(loinc_code)
    haml_tag :div, :class => 'tools', :style => "position: absolute; right: 15px;" do
      haml_concat link_to_unless_current('Show', loinc_code)
      haml_concat "|"
      haml_concat link_to_unless_current('Edit', edit_loinc_code_path(loinc_code))
      haml_concat "|"
      haml_concat link_to('Delete', loinc_code, :method => :delete, :confirm => 'Are you sure?')
    end
  end

end
