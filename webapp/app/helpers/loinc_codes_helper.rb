module LoincCodesHelper

  def loinc_code_tools(loinc_code)
    haml_tag :div, :class => 'tools' do
      haml_concat link_to_unless_current('Show', loinc_code)
      haml_concat "&nbsp;|&nbsp;"
      haml_concat link_to_unless_current('Edit', edit_loinc_code_path(loinc_code))
      if current_page_is_loinc_page? loinc_code
        haml_concat "&nbsp;|&nbsp;"
        haml_concat link_to('Delete', loinc_code, :method => :delete, :confirm => 'Are you sure?')
      end
    end
  end

  def select_options_loinc_scales
    CodeName.loinc_scale.external_codes.sort_by(&:sort_order).collect do |code|
      [code.code_description, code.id]
    end
  end

  def select_options_organisms
    Organism.all(:order => 'organism_name').collect do |organism|
      [organism.organism_name, organism.id]
    end
  end

  def select_options_common_test_types
    CommonTestType.all(:order => 'common_name').collect do |ctt|
      [ctt.common_name, ctt.id]
    end
  end

  def update_organism_select(form)
    organism_id   = form.field_id   :organism_id
    organism_name = form.field_name :organism_id
    scale_id      = form.field_id   :scale_id
    organism_scales = LoincCode.scales_compatible_with_organisms.collect{|code| "'#{code.id}'"}.join(",")
    js = <<-"javascript:end"
      if ([#{organism_scales}].include($F('#{scale_id}'))) {
        if ($('#{organism_id}_hidden') != null) {
          $('#{organism_id}_hidden').remove();
        }
        $('#{organism_id}').enable();
      } else {
        $('#{organism_id}').value = "";
        $('#{organism_id}').insert({after: '#{hidden_field_tag(organism_id + "_hidden", Hash.new, :name => organism_name, :value => '')}'})
        $('#{organism_id}').disable();
      }
    javascript:end
  end

  def observable_fields_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for record_or_name_or_array, *(args << options.merge(:builder => ObservableFieldsFormBuilder)), &proc
  end

  def current_page_is_loinc_page?(loinc)
    [loinc_codes_path, loinc_code_path(loinc), edit_loinc_code_path(loinc)].any? do |path|
      current_page? path
    end
  end
end
