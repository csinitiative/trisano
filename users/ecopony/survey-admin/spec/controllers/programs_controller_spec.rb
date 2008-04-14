require File.dirname(__FILE__) + '/../spec_helper'

describe ProgramsController do
  describe "handling GET /programs" do

    before(:each) do
      @program = mock_model(Program)
      Program.stub!(:find).and_return([@program])
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
  
    it "should find all programs" do
      Program.should_receive(:find).with(:all).and_return([@program])
      do_get
    end
  
    it "should assign the found programs for the view" do
      do_get
      assigns[:programs].should == [@program]
    end
  end

  describe "handling GET /programs.xml" do

    before(:each) do
      @program = mock_model(Program, :to_xml => "XML")
      Program.stub!(:find).and_return(@program)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all programs" do
      Program.should_receive(:find).with(:all).and_return([@program])
      do_get
    end
  
    it "should render the found programs as xml" do
      @program.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /programs/1" do

    before(:each) do
      @program = mock_model(Program)
      Program.stub!(:find).and_return(@program)
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
  
    it "should find the program requested" do
      Program.should_receive(:find).with("1").and_return(@program)
      do_get
    end
  
    it "should assign the found program for the view" do
      do_get
      assigns[:program].should equal(@program)
    end
  end

  describe "handling GET /programs/1.xml" do

    before(:each) do
      @program = mock_model(Program, :to_xml => "XML")
      Program.stub!(:find).and_return(@program)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the program requested" do
      Program.should_receive(:find).with("1").and_return(@program)
      do_get
    end
  
    it "should render the found program as xml" do
      @program.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /programs/new" do

    before(:each) do
      @program = mock_model(Program)
      Program.stub!(:new).and_return(@program)
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
  
    it "should create an new program" do
      Program.should_receive(:new).and_return(@program)
      do_get
    end
  
    it "should not save the new program" do
      @program.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new program for the view" do
      do_get
      assigns[:program].should equal(@program)
    end
  end

  describe "handling GET /programs/1/edit" do

    before(:each) do
      @program = mock_model(Program)
      Program.stub!(:find).and_return(@program)
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
  
    it "should find the program requested" do
      Program.should_receive(:find).and_return(@program)
      do_get
    end
  
    it "should assign the found Program for the view" do
      do_get
      assigns[:program].should equal(@program)
    end
  end

  describe "handling POST /programs" do

    before(:each) do
      @program = mock_model(Program, :to_param => "1")
      Program.stub!(:new).and_return(@program)
    end
    
    describe "with successful save" do
  
      def do_post
        @program.should_receive(:save).and_return(true)
        post :create, :program => {}
      end
  
      it "should create a new program" do
        Program.should_receive(:new).with({}).and_return(@program)
        do_post
      end

      it "should redirect to the new program" do
        do_post
        response.should redirect_to(program_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @program.should_receive(:save).and_return(false)
        post :create, :program => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /programs/1" do

    before(:each) do
      @program = mock_model(Program, :to_param => "1")
      Program.stub!(:find).and_return(@program)
    end
    
    describe "with successful update" do

      def do_put
        @program.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the program requested" do
        Program.should_receive(:find).with("1").and_return(@program)
        do_put
      end

      it "should update the found program" do
        do_put
        assigns(:program).should equal(@program)
      end

      it "should assign the found program for the view" do
        do_put
        assigns(:program).should equal(@program)
      end

      it "should redirect to the program" do
        do_put
        response.should redirect_to(program_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @program.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /programs/1" do

    before(:each) do
      @program = mock_model(Program, :destroy => true)
      Program.stub!(:find).and_return(@program)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the program requested" do
      Program.should_receive(:find).with("1").and_return(@program)
      do_delete
    end
  
    it "should call destroy on the found program" do
      @program.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the programs list" do
      do_delete
      response.should redirect_to(programs_url)
    end
  end
end