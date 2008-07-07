require File.dirname(__FILE__) + '/../spec_helper'

describe FormsController do
  describe "handling GET /forms" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return([@form])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all forms" do
      Form.should_receive(:find).and_return([@form])
      do_get
    end
  
    it "should assign the found forms for the view" do
      do_get
      assigns[:forms].should == [@form]
    end
  end

  describe "handling GET /forms.xml" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_xml => "XML")
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all forms" do
      Form.should_receive(:find).and_return([@form])
      do_get
    end
  
    it "should render the found forms as xml" do
      @form.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_get
    end
  
    it "should assign the found form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling GET /forms/1.xml" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_xml => "XML")
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_get
    end
  
    it "should render the found form as xml" do
      @form.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forms/new" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:new).and_return(@form)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new form" do
      Form.should_receive(:new).and_return(@form)
      do_get
    end
  
    it "should not save the new form" do
      @form.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling GET /forms/1/edit" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).and_return(@form)
      do_get
    end
  
    it "should assign the found Form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end

  describe "handling POST /forms" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      Form.stub!(:new).and_return(@form)
    end
    
    describe "with successful save" do
  
      def do_post
        @form.should_receive(:save_and_initialize_form_elements).and_return(true)
        post :create, :form => {}
      end
  
      it "should create a new form" do
        Form.should_receive(:new).with({}).and_return(@form)
        do_post
      end

      it "should redirect to the new form" do
        do_post
        response.should redirect_to(form_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @form.should_receive(:save_and_initialize_form_elements).and_return(false)
        post :create, :form => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      Form.stub!(:find).and_return(@form)
    end
    
    describe "with successful update" do

      def do_put
        @form.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the form requested" do
        Form.should_receive(:find).with("1").and_return(@form)
        do_put
      end

      it "should update the found form" do
        do_put
        assigns(:form).should equal(@form)
      end

      it "should assign the found form for the view" do
        do_put
        assigns(:form).should equal(@form)
      end

      it "should redirect to the form" do
        do_put
        response.should redirect_to(form_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @form.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /forms/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :destroy => true)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the form requested" do
      Form.should_receive(:find).with("1").and_return(@form)
      do_delete
    end
  
    it "should call destroy on the found form" do
      @form.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the forms list" do
      do_delete
      response.should redirect_to(forms_url)
    end
  end
  
  describe "handling GET /forms/builder/1" do

    before(:each) do
      mock_user
      @form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_get
      get :builder, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render builder template" do
      do_get
      response.should render_template('builder')
    end
  
    it "should find the form requested" do
      Form.should_receive(:find).and_return(@form)
      do_get
    end
  
    it "should assign the found Form for the view" do
      do_get
      assigns[:form].should equal(@form)
    end
  end
  
  describe "handling POST /forms/order_section_children" do

    before(:each) do
      mock_user
      @reorder_list = ["5", "6", "7"]
      @section = mock_model(SectionElement)
      @form = mock_model(Form)
      reorder_ids = @reorder_list.collect {|id| id.to_i}
      @section.stub!(:reorder_children).with(reorder_ids)
      @section.stub!(:form_id).and_return(1)
      FormElement.stub!(:find).and_return(@section)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_post
      post :order_section_children, :id => "3", 'reorder-list' => @reorder_list
    end

    it "should be successful" do
      pending "Will rework soon"
      do_post
      response.should be_success
    end
  
    it "should render reorder_section_children template" do
      pending "Will rework soon"
      do_post
      response.should render_template('forms/order_section_children')
    end
  
    it "should find the section requested" do
      pending "Will rework soon"
      FormElement.should_receive(:find).with("3").and_return(@section)
      do_post
    end
    
    it "should call reorder_children on the found section" do
      pending "Will rework soon"
      @section.should_receive(:reorder_children)
      do_post
    end
    
    it "should render error template in case of error" do
      pending "Will rework soon"
      @section.stub!(:reorder_children).and_raise(Exception)
      do_post
      response.should render_template('rjs-error')
    end
  
  end
  
  describe "handling POST /forms/publish" do

    before(:each) do
      mock_user
      @form = mock_model(Form, :to_param => "1")
      @published_form = mock_model(Form)
      Form.stub!(:find).and_return(@form)
    end
  
    def do_post
      post :publish, :id => "1"
    end
    
    it "should re-direct to forms index on success" do
      @form.stub!(:publish!).and_return(@published_form)
      do_post
      response.should redirect_to(forms_path)
    end
    
    it "should re-render the builder template on failure" do
      @form.stub!(:publish!).and_raise(Exception)
      do_post
      response.should render_template('builder')
    end

  end
  
  describe "handling POST /question_elements/to_library" do
    
    before(:each) do
      mock_user
      @question_reference = mock_model(QuestionElement)
      @string = mock(String)
      @string.stub!(:humanize).and_return("")
      @question_reference.stub!(:type).and_return(@string)
      FormElement.stub!(:find).and_return(@question_reference)
    end
    
    def do_post
      post :to_library, :group_element_id => "root", :reference_element_id => "1"
    end

    it "should render library elements partial on success" do
      @question_reference.stub!(:add_to_library).and_return(true)
      do_post
      response.should render_template('forms/_library_elements')
    end
    
    it "should render rjs error template on failure" do
      @question_reference.stub!(:add_to_library).and_return(false)
      do_post
      response.should render_template('rjs-error')
    end
  end
  
  describe "handling POST /question_elements/from_library" do
    
    before(:each) do
      mock_user
      @form = mock_model(Form)
      @form_element = mock_model(FormElement)
      @string = mock(String)
      @string.stub!(:humanize).and_return("")
      @form_element.stub!(:type).and_return(@string)
      @form_element.stub!(:form_id).and_return("1")
      FormElement.stub!(:find).and_return(@form_element)
      Form.stub!(:find).and_return(@form)
    end
    
    def do_post
      post :from_library, :reference_element_id => "1", :lib_element_id => "2"
    end

    it "should render forms/_elements partial on success with the investigator view branch of the form tree" do
      @ancestors = [nil, InvestigatorViewElementContainer.new]
      @form_element.stub!(:ancestors).and_return(@ancestors)
      @form_element.stub!(:copy_from_library).with("2").and_return(true)
      do_post
      response.should render_template('forms/_elements')
    end
    
    it "should render forms/_core_elements partial on success with the core view branch of the form tree" do
      @ancestors = [nil, CoreViewElementContainer.new]
      @form_element.stub!(:ancestors).and_return(@ancestors)
      @form_element.stub!(:copy_from_library).with("2").and_return(true)
      do_post
      response.should render_template('forms/_core_elements')
    end
    
    it "should render rjs error template on failure" do
      @form_element.stub!(:copy_from_library).with("2").and_return(false)
      do_post
      response.should render_template('rjs-error')
    end
  end
  
end
