require File.dirname(__FILE__) + '/../spec_helper'

describe FollowUpElementsController do
  describe "handling GET /follow_up_elements" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:find).and_return([@follow_up_element])
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
  
    it "should find all follow_up_elements" do
      FollowUpElement.should_receive(:find).with(:all).and_return([@follow_up_element])
      do_get
    end
  
    it "should assign the found follow_up_elements for the view" do
      do_get
      assigns[:follow_up_elements].should == [@follow_up_element]
    end
  end

  describe "handling GET /follow_up_elements.xml" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_xml => "XML")
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all follow_up_elements" do
      FollowUpElement.should_receive(:find).with(:all).and_return([@follow_up_element])
      do_get
    end
  
    it "should render the found follow_up_elements as xml" do
      @follow_up_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /follow_up_elements/1" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
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
  
    it "should find the follow_up_element requested" do
      FollowUpElement.should_receive(:find).with("1").and_return(@follow_up_element)
      do_get
    end
  
    it "should assign the found follow_up_element for the view" do
      do_get
      assigns[:follow_up_element].should equal(@follow_up_element)
    end
  end

  describe "handling GET /follow_up_elements/1.xml" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_xml => "XML")
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the follow_up_element requested" do
      FollowUpElement.should_receive(:find).with("1").and_return(@follow_up_element)
      do_get
    end
  
    it "should render the found follow_up_element as xml" do
      @follow_up_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /follow_up_elements/new" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:new).and_return(@follow_up_element)
      @follow_up_element.stub!(:parent_element_id=)
      @follow_up_element.stub!(:core_data=)
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
  
    it "should create an new follow_up_element" do
      FollowUpElement.should_receive(:new).and_return(@follow_up_element)
      do_get
    end
  
    it "should not save the new follow_up_element" do
      @follow_up_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new follow_up_element for the view" do
      do_get
      assigns[:follow_up_element].should equal(@follow_up_element)
    end
  end

  describe "handling GET /follow_up_elements/1/edit" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement)
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
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
  
    it "should find the follow_up_element requested" do
      FollowUpElement.should_receive(:find).and_return(@follow_up_element)
      do_get
    end
  
    it "should assign the found FollowUpElement for the view" do
      do_get
      assigns[:follow_up_element].should equal(@follow_up_element)
    end
  end

  describe "handling POST /follow_up_elements" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_param => "1")
      @follow_up_element.stub!(:form_id).and_return(1)
      FollowUpElement.stub!(:new).and_return(@follow_up_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @follow_up_element.should_receive(:save_and_add_to_form).and_return(true)
        Form.stub!(:find).with(1).and_return(mock_model(Form))
        post :create, :follow_up_element => {}
      end
  
      it "should create a new follow_up_element" do
        FollowUpElement.should_receive(:new).with({}).and_return(@follow_up_element)
        do_post
      end

      it "should render the create template" do
        do_post
        response.should render_template('create')
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @request.env["HTTP_ACCEPT"] = "application/javascript"
        @follow_up_element.should_receive(:save_and_add_to_form).and_return(false)
        post :create, :follow_up_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /follow_up_elements/1" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :to_param => "1")
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
    end
    
    describe "with successful update" do

      def do_put
        @follow_up_element.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the follow_up_element requested" do
        FollowUpElement.should_receive(:find).with("1").and_return(@follow_up_element)
        do_put
      end

      it "should update the found follow_up_element" do
        do_put
        assigns(:follow_up_element).should equal(@follow_up_element)
      end

      it "should assign the found follow_up_element for the view" do
        do_put
        assigns(:follow_up_element).should equal(@follow_up_element)
      end

      it "should redirect to the follow_up_element" do
        do_put
        response.should redirect_to(follow_up_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @follow_up_element.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /follow_up_elements/1" do

    before(:each) do
      mock_user
      @follow_up_element = mock_model(FollowUpElement, :destroy => true)
      FollowUpElement.stub!(:find).and_return(@follow_up_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the follow_up_element requested" do
      FollowUpElement.should_receive(:find).with("1").and_return(@follow_up_element)
      do_delete
    end
  
    it "should call destroy on the found follow_up_element" do
      @follow_up_element.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the follow_up_elements list" do
      do_delete
      response.should redirect_to(follow_up_elements_url)
    end
  end
end