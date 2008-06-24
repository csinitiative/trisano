require File.dirname(__FILE__) + '/../spec_helper'

describe CoreViewElementsController do
  describe "handling GET /core_view_elements" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement)
      CoreViewElement.stub!(:find).and_return([@core_view_element])
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
  
    it "should find all core_view_elements" do
      CoreViewElement.should_receive(:find).with(:all).and_return([@core_view_element])
      do_get
    end
  
    it "should assign the found core_view_elements for the view" do
      do_get
      assigns[:core_view_elements].should == [@core_view_element]
    end
  end

  describe "handling GET /core_view_elements.xml" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement, :to_xml => "XML")
      CoreViewElement.stub!(:find).and_return(@core_view_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all core_view_elements" do
      CoreViewElement.should_receive(:find).with(:all).and_return([@core_view_element])
      do_get
    end
  
    it "should render the found core_view_elements as xml" do
      @core_view_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /core_view_elements/1" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement)
      CoreViewElement.stub!(:find).and_return(@core_view_element)
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
  
    it "should find the core_view_element requested" do
      CoreViewElement.should_receive(:find).with("1").and_return(@core_view_element)
      do_get
    end
  
    it "should assign the found core_view_element for the view" do
      do_get
      assigns[:core_view_element].should equal(@core_view_element)
    end
  end

  describe "handling GET /core_view_elements/1.xml" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement, :to_xml => "XML")
      CoreViewElement.stub!(:find).and_return(@core_view_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the core_view_element requested" do
      CoreViewElement.should_receive(:find).with("1").and_return(@core_view_element)
      do_get
    end
  
    it "should render the found core_view_element as xml" do
      @core_view_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /core_view_elements/new" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement)
      CoreViewElement.stub!(:new).and_return(@core_view_element)
      @core_view_element.stub!(:available_core_views).and_return([])
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
  
    it "should create an new core_view_element" do
      CoreViewElement.should_receive(:new).and_return(@core_view_element)
      do_get
    end
  
    it "should not save the new core_view_element" do
      @core_view_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new core_view_element for the view" do
      do_get
      assigns[:core_view_element].should equal(@core_view_element)
    end
  end

  describe "handling GET /core_view_elements/1/edit" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement)
      CoreViewElement.stub!(:find).and_return(@core_view_element)
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
  
    it "should find the core_view_element requested" do
      CoreViewElement.should_receive(:find).and_return(@core_view_element)
      do_get
    end
  
    it "should assign the found CoreViewElement for the view" do
      do_get
      assigns[:core_view_element].should equal(@core_view_element)
    end
  end

  describe "handling POST /core_view_elements" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement, :to_param => "1")
      @core_view_element.stub!(:form_id).and_return(1)
      CoreViewElement.stub!(:new).and_return(@core_view_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @core_view_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :core_view_element => {}
      end
  
      it "should create a new core_view_element" do
        CoreViewElement.should_receive(:new).with({}).and_return(@core_view_element)
        do_post
      end

      it "should redirect to the new core_view_element" do
        do_post
        response.should render_template('create')
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @core_view_element.should_receive(:save_and_add_to_form).and_return(false)
        @core_view_element.stub!(:available_core_views).and_return([])
        post :create, :core_view_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /core_view_elements/1" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement, :to_param => "1")
      CoreViewElement.stub!(:find).and_return(@core_view_element)
    end
    
    describe "with successful update" do

      def do_put
        @core_view_element.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the core_view_element requested" do
        CoreViewElement.should_receive(:find).with("1").and_return(@core_view_element)
        do_put
      end

      it "should update the found core_view_element" do
        do_put
        assigns(:core_view_element).should equal(@core_view_element)
      end

      it "should assign the found core_view_element for the view" do
        do_put
        assigns(:core_view_element).should equal(@core_view_element)
      end

      it "should redirect to the core_view_element" do
        do_put
        response.should redirect_to(core_view_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @core_view_element.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /core_view_elements/1" do

    before(:each) do
      mock_user
      @core_view_element = mock_model(CoreViewElement, :destroy => true)
      CoreViewElement.stub!(:find).and_return(@core_view_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the core_view_element requested" do
      CoreViewElement.should_receive(:find).with("1").and_return(@core_view_element)
      do_delete
    end
  
    it "should call destroy on the found core_view_element" do
      @core_view_element.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the core_view_elements list" do
      do_delete
      response.should redirect_to(core_view_elements_url)
    end
  end
end