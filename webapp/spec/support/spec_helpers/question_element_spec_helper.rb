module QuestionElementSpecHelper

  def with_question_element
    form = Form.new(:name => "Test Form", :event_type => 'morbidity_event')
    form.short_name = "short_name_editable_#{rand(20000)}"
    form.save_and_initialize_form_elements
    section_element = SectionElement.new(:name => "Test")
    section_element.parent_element_id = form.investigator_view_elements_container.children[0]
    section_element.save_and_add_to_form.should_not be_nil
    question_element = QuestionElement.new({
        :parent_element_id => section_element.id,
        :question_attributes => {:question_text => "Did you eat the fish?", :data_type => "single_line_text", :short_name => "fishy"}
      })
    yield question_element if block_given?
  end

end
