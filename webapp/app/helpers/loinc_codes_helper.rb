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

  def update_organism_select(form)
    organism_id   = form.field_id   :organism_id
    organism_name = form.field_name :organism_id
    scale_id      = form.field_id   :scale_id
    js = <<-"javascript:end"
      if ($F('#{scale_id}') == "174") {
        $('#{organism_id}').value = "";
        $('#{organism_id}').insert({after: '#{hidden_field_tag(organism_id + "_hidden", Hash.new, :name => organism_name, :value => '')}'})
        $('#{organism_id}').disable();
      } else {
        if ($('#{organism_id}_hidden') != null) {
          $('#{organism_id}_hidden').remove();
        }
        $('#{organism_id}').enable();
      }
    javascript:end
  end

  def observable_fields_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for record_or_name_or_array, *(args << options.merge(:builder => ObservableFieldsFormBuilder)), &proc
  end

end
