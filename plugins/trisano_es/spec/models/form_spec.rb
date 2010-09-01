require 'spec_helper'

describe Form, "in Spanish" do

  before do
    I18n.locale = :es
    @form = Form.new
    @form.name = "Test Form"
    @form.event_type = 'morbidity_event'
    @form.short_name = 'test_form'
  end

  after do
    I18n.locale = :en
  end

  it "should bootstrap with default view in spanish" do
    @form.save_and_initialize_form_elements
    form_base_element = @form.form_base_element
    form_base_element.should_not be_nil

    investigator_view_element_container = form_base_element.children[0]

    default_view_element = investigator_view_element_container.children[0]
    default_view_element.should_not be_nil
    default_view_element.name.should == "Vista predeterminada"
  end

end
