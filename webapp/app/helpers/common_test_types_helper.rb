module CommonTestTypesHelper

  def common_test_type_tools(common_test_type)
    haml_tag :div, :class => 'tools', :style => "position: absolute; right: 15px;" do
      haml_concat link_to_unless_current('Show', common_test_type)
      haml_concat "|"
      haml_concat link_to_unless_current('Edit', edit_common_test_type_path(common_test_type))
    end
  end

end
