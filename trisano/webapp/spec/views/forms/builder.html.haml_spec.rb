require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forms/builder.html.haml" do
  include FormsHelper
  
  before(:each) do
    @form = mock_model(Form)
    @base_element = mock_model(FormBaseElement)
    @investigator_view_element_container = mock_model(InvestigatorViewElementContainer)
    @core_view_element_container = mock_model(CoreViewElementContainer)
    @core_field_element_container = mock_model(CoreFieldElementContainer)
    @view_element = mock_model(ViewElement)
    @section_element = mock_model(SectionElement)
    @question_element = mock_model(QuestionElement)
    @question = mock_model(Question)
    
    @place = mock_model(Place)
    @place.stub!(:name).and_return("Davis")
    @entity = mock_model(Entity)
    @entity.stub!(:current_place).and_return(@place)
    
    @disease = mock_model(Disease)
    @disease.stub!(:disease_name).and_return("Anthrax")
    
    @form = mock_model(Form)
    @form.stub!(:name).and_return("Anthrax Form")
    @form.stub!(:description).and_return("Questions to ask when disease is Anthrax")
    @form.stub!(:diseases).and_return([@disease])
    @form.stub!(:jurisdiction).and_return(@entity)
    @form.stub!(:status).and_return('Not Published')
    
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:form_base_element).and_return(@base_element)
    @form.stub!(:investigator_view_elements_container).and_return(@investigator_view_element_container)
    @form.stub!(:core_view_elements_container).and_return(@core_view_element_container)
    @form.stub!(:core_field_elements_container).and_return(@core_view_element_container)

    

    
    @core_view_element_container.stub!(:children).and_return([@view_element])
    @investigator_view_element_container.stub!(:children).and_return([])
    @view_element.stub!(:children).and_return([@section_element])
    @view_element.stub!(:name).and_return("Default View")
    @view_element.stub!(:children?).and_return(true)
    @section_element.stub!(:name).and_return("Section Name")
    @section_element.stub!(:children?).and_return(true)
    @section_element.stub!(:children).and_return([@question_element])
    @question_element.stub!(:question).and_return(@question)
    @question_element.stub!(:children?).and_return(false)
    @question_element.stub!(:form_id).and_return(1)
    @question_element.stub!(:is_multi_valued_and_empty?).and_return(false)
    @question_element.stub!(:in_library?).and_return(false)
    @question_element.stub!(:is_active).and_return(true)
    @question_element.stub!(:is_active?).and_return(true)
    @question_element.stub!(:pre_order_walk).and_yield(nil)
    @question.stub!(:question_text).and_return("Que?")
    @question.stub!(:data_type).and_return("single_line_input")
    @question.stub!(:short_name).and_return("")
    @question.stub!(:data_type_before_type_cast).and_return("single_line_input")
    @question.stub!(:core_data).and_return(false)
    @question.stub!(:core_data?).and_return(false)
    
    assigns[:form] = @form
    assigns[:library_elements] = [@question_element]
  end

  it "should have basic form info and links'" do
    render "/forms/builder.html.haml"
    response.should have_text(/Add question to tab/)
    
  end
end
