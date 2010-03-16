When /^I create a question element with blank question text$/ do
  visit(question_elements_path,
        :post,
        :question_element => {
          :parent_element_id => @form.form_base_element.id,
          :question_attributes => {
            :short_name => 'blah',
            :data_type => 'drop_down'}})
end

