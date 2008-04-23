require File.dirname(__FILE__) + '/../spec_helper'

describe SectionsController do
  describe "handling GET /sections" do

    before(:each) do
      @section = mock_model(Section)
      Section.stub!(:find).and_return([@section])
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
  
    it "should find all sections" do
      Section.should_receive(:find).and_return([@section])
      do_get
    end
  
    it "should assign the found sections for the view" do
      do_get
      assigns[:sections].should == [@section]
    end
  end

  describe "handling GET /sections.xml" do

    before(:each) do
      @section = mock_model(Section, :to_xml => "XML")
      Section.stub!(:find).and_return(@section)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all sections" do
      Section.should_receive(:find).and_return([@section])
      do_get
    end
  
    it "should render the found sections as xml" do
      @section.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /sections/1" do

    before(:each) do
      @section = mock_model(Section)
      Section.stub!(:find).and_return(@section)
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
  
    it "should find the section requested" do
      Section.should_receive(:find).with("1").and_return(@section)
      do_get
    end
  
    it "should assign the found section for the view" do
      do_get
      assigns[:section].should equal(@section)
    end
  end

  describe "handling GET /sections/1.xml" do

    before(:each) do
      @section = mock_model(Section, :to_xml => "XML")
      Section.stub!(:find).and_return(@section)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the section requested" do
      Section.should_receive(:find).with("1").and_return(@section)
      do_get
    end
  
    it "should render the found section as xml" do
      @section.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /sections/new" do

    before(:each) do
      @section = mock_model(Section)
      Section.stub!(:new).and_return(@section)
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
  
    it "should create an new section" do
      Section.should_receive(:new).and_return(@section)
      do_get
    end
  
    it "should not save the new section" do
      @section.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new section for the view" do
      do_get
      assigns[:section].should equal(@section)
    end
  end

  describe "handling GET /sections/1/edit" do

    before(:each) do
      @section = mock_model(Section)
      Section.stub!(:find).and_return(@section)
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
  
    it "should find the section requested" do
      Section.should_receive(:find).and_return(@section)
      do_get
    end
  
    it "should assign the found Section for the view" do
      do_get
      assigns[:section].should equal(@section)
    end
  end

  describe "handling POST /sections" do

    before(:each) do
      @section = mock_model(Section, :to_param => "1")
      Section.stub!(:new).and_return(@section)
    end
    
    describe "with successful save" do
  
      def do_post
        @section.should_receive(:save).and_return(true)
        post :create, :section => {}
      end
  
      it "should create a new section" do
        Section.should_receive(:new).with({}).and_return(@section)
        do_post
      end

      it "should redirect to the new section" do
        do_post
        response.should redirect_to(section_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @section.should_receive(:save).and_return(false)
        post :create, :section => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /sections/1" do

    before(:each) do
      @section = mock_model(Section, :to_param => "1")
      Section.stub!(:find).and_return(@section)
    end
    
    describe "with successful update" do

      def do_put
        @section.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the section requested" do
        Section.should_receive(:find).with("1").and_return(@section)
        do_put
      end

      it "should update the found section" do
        do_put
        assigns(:section).should equal(@section)
      end

      it "should assign the found section for the view" do
        do_put
        assigns(:section).should equal(@section)
      end

      it "should redirect to the section" do
        do_put
        response.should redirect_to(section_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @section.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /sections/1" do

    before(:each) do
      @section = mock_model(Section, :destroy => true)
      Section.stub!(:find).and_return(@section)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the section requested" do
      Section.should_receive(:find).with("1").and_return(@section)
      do_delete
    end
  
    it "should call destroy on the found section" do
      @section.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the sections list" do
      do_delete
      response.should redirect_to(sections_url)
    end
  end
end