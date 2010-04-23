When /^I add a tab named "([^\"]*)"$/ do |tab_name|
  http_accept('js')
  visit('/view_elements', :post, {
          'view_element[name]' => tab_name,
          'view_element[parent_element_id]' => @form.investigator_view_elements_container.id
        })
end
