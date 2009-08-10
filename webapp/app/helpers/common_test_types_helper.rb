module CommonTestTypesHelper

  def common_test_type_tools(common_test_type)
    haml_tag :div, :class => 'tools', :style => "position: absolute; right: 15px;" do
      haml_concat link_to_unless_current('Show', common_test_type)
      haml_concat "|"
      haml_concat link_to_unless_current('Edit', edit_common_test_type_path(common_test_type))
      haml_concat "|"
      haml_concat link_to_unless_current('LOINC Codes', loinc_codes_common_test_type_path(common_test_type))
    end
  end

  def check_box_tag_add_loinc_code(loinc_code)
    check_box_tag("added_loinc_codes[]",
                  loinc_code.id,
                  false,
                  :id => h(loinc_code.loinc_code))
  end

  def check_box_tag_remove_loinc_code(loinc_code)
    check_box_tag("removed_loinc_codes[]",
                  loinc_code.id,
                  false,
                  :id => h(loinc_code.loinc_code))
  end

  def link_to_associated_common_test_type(loinc_code)
    link_to_if(loinc_code.common_test_type,
               h(loinc_code.common_test_type.try(:common_name)),
               loinc_code.common_test_type)
  end
end
