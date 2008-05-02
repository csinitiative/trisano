require File.dirname(__FILE__) + '/../spec_helper'

describe ValueSetElementsController do
  describe "handling GET /value_set_elements" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement)
      ValueSetElement.stub!(:find).and_return([@value_set_element])
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
  
    it "should find all value_set_elements" do
      ValueSetElement.should_receive(:find).with(:all).and_return([@value_set_element])
      do_get
    end
  
    it "should assign the found value_set_elements for the view" do
      do_get
      assigns[:value_set_elements].should == [@value_set_element]
    end
  end

  describe "handling GET /value_set_elements.xml" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement, :to_xml => "XML")
      ValueSetElement.stub!(:find).and_return(@value_set_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all value_set_elements" do
      ValueSetElement.should_receive(:find).with(:all).and_return([@value_set_element])
      do_get
    end
  
    it "should render the found value_set_elements as xml" do
      @value_set_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement)
      ValueSetElement.stub!(:find).and_return(@value_set_element)
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
  
    it "should find the value_set_element requested" do
      ValueSetElement.should_receive(:find).with("1").and_return(@value_set_element)
      do_get
    end
  
    it "should assign the found value_set_element for the view" do
      do_get
      assigns[:value_set_element].should equal(@value_set_element)
    end
  end

  describe "handling GET /value_set_elements/1.xml" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement, :to_xml => "XML")
      ValueSetElement.stub!(:find).and_return(@value_set_element)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the value_set_element requested" do
      ValueSetElement.should_receive(:find).with("1").and_return(@value_set_element)
      do_get
    end
  
    it "should render the found value_set_element as xml" do
      @value_set_element.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /value_set_elements/new" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement)
      ValueSetElement.stub!(:new).and_return(@value_set_element)
      @value_set_element.stub!(:parent_element_id=)
      @value_set_element.stub!(:form_id=)
    end
  
    def do_get
      get :new, :parent_element_id => 5, :form_id => 1
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new value_set_element" do
      ValueSetElement.should_receive(:new).and_return(@value_set_element)
      do_get
    end
  
    it "should not save the new value_set_element" do
      @value_set_element.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new value_set_element for the view" do
      do_get
      assigns[:value_set_element].should equal(@value_set_element)
    end
  end

  describe "handling GET /value_set_elements/1/edit" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement)
      ValueSetElement.stub!(:find).and_return(@value_set_element)
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
  
    it "should find the value_set_element requested" do
      ValueSetElement.should_receive(:find).and_return(@value_set_element)
      do_get
    end
  
    it "should assign the found ValueSetElement for the view" do
      do_get
      assigns[:value_set_element].should equal(@value_set_element)
    end
  end

  describe "handling POST /value_set_elements" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement, :to_param => "1")
      ValueSetElement.stub!(:new).and_return(@value_set_element)
    end
    
    describe "with successful save" do
  
      def do_post
        @value_set_element.should_receive(:save_and_add_to_form).and_return(true)
        post :create, :value_set_element => {}
      end
  
      it "should create a new value_set_element" do
        ValueSetElement.should_receive(:new).with({}).and_return(@value_set_element)
        do_post
      end

      it "should redirect to the new value_set_element" do
        do_post
        response.should redirect_to(value_set_element_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @value_set_element.should_receive(:save_and_add_to_form).and_return(false)
        post :create, :value_set_element => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement, :to_param => "1")
      ValueSetElement.stub!(:find).and_return(@value_set_element)
    end
    
    describe "with successful update" do

      def do_put
        @value_set_element.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the value_set_element requested" do
        ValueSetElement.should_receive(:find).with("1").and_return(@value_set_element)
        do_put
      end

      it "should update the found value_set_element" do
        do_put
        assigns(:value_set_element).should equal(@value_set_element)
      end

      it "should assign the found value_set_element for the view" do
        do_put
        assigns(:value_set_element).should equal(@value_set_element)
      end

      it "should redirect to the value_set_element" do
        do_put
        response.should redirect_to(value_set_element_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @value_set_element.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /value_set_elements/1" do

    before(:each) do
      mock_user
      @value_set_element = mock_model(ValueSetElement, :destroy => true)
      ValueSetElement.stub!(:find).and_return(@value_set_element)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the value_set_element requested" do
      ValueSetElement.should_receive(:find).with("1").and_return(@value_set_element)
      do_delete
    end
  
    it "should call destroy on the found value_set_element" do
      @value_set_element.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the value_set_elements list" do
      do_delete
      response.should redirect_to(value_set_elements_url)
    end
  end
end