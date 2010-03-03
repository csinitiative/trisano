module CommonTestTypesHelper

  def common_test_type_tools(common_test_type)
    haml_tag :div, :class => 'tools' do
      haml_concat link_to_unless_current(t('show'), common_test_type)
      haml_concat "|"
      haml_concat link_to_unless_current(t('edit'), edit_common_test_type_path(common_test_type))
      if current_page_is_common_test_type_page? common_test_type
        haml_concat "|"
        haml_concat link_to_unless_current(t('loinc_codes'), loinc_codes_common_test_type_path(common_test_type))
        haml_concat "|"
        haml_concat link_to_if(common_test_type.lab_results.empty?,
                               t('delete'),
                               common_test_type_path(common_test_type),
                               :method => :delete,
                               :confirm => t('are_you_sure'))
      end
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

  def current_page_is_common_test_type_page?(ctt)
    [common_test_types_path,
     common_test_type_path(ctt),
     edit_common_test_type_path(ctt),
     update_loincs_common_test_type_path(ctt),
     loinc_codes_common_test_type_path(ctt)
    ].any? do |path|
      current_page? path
    end
  end

end
