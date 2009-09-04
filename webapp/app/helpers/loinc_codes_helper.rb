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

  def select_options_loinc_scales
    CodeName.loinc_scale.external_codes.sort_by(&:sort_order).collect do |code|
      [code.code_description, code.id]
    end
  end

  def select_options_organisms
    Organism.all.collect do |organism|
      [organism.organism_name, organism.id]
    end
  end
end
