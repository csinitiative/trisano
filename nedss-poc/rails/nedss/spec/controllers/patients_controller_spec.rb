require File.dirname(__FILE__) + '/../spec_helper'

describe PatientsController do
  describe "handling GET /patients" do

    before(:each) do
      @patient = mock_model(Patient)
      Patient.stub!(:find).and_return([@patient])
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
  
    it "should find all patients" do
      Patient.should_receive(:find).with(:all).and_return([@patient])
      do_get
    end
  
    it "should assign the found patients for the view" do
      do_get
      assigns[:patients].should == [@patient]
    end
  end

  describe "handling GET /patients.xml" do

    before(:each) do
      @patient = mock_model(Patient, :to_xml => "XML")
      Patient.stub!(:find).and_return(@patient)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all patients" do
      Patient.should_receive(:find).with(:all).and_return([@patient])
      do_get
    end
  
    it "should render the found patients as xml" do
      @patient.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /patients/1" do

    before(:each) do
      @patient = mock_model(Patient)
      Patient.stub!(:find).and_return(@patient)
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
  
    it "should find the patient requested" do
      Patient.should_receive(:find).with("1").and_return(@patient)
      do_get
    end
  
    it "should assign the found patient for the view" do
      do_get
      assigns[:patient].should equal(@patient)
    end
  end

  describe "handling GET /patients/1.xml" do

    before(:each) do
      @patient = mock_model(Patient, :to_xml => "XML")
      Patient.stub!(:find).and_return(@patient)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the patient requested" do
      Patient.should_receive(:find).with("1").and_return(@patient)
      do_get
    end
  
    it "should render the found patient as xml" do
      @patient.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /patients/new" do

    before(:each) do
      @patient = mock_model(Patient)
      Patient.stub!(:new).and_return(@patient)
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
  
    it "should create an new patient" do
      Patient.should_receive(:new).and_return(@patient)
      do_get
    end
  
    it "should not save the new patient" do
      @patient.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new patient for the view" do
      do_get
      assigns[:patient].should equal(@patient)
    end
  end

  describe "handling GET /patients/1/edit" do

    before(:each) do
      @patient = mock_model(Patient)
      Patient.stub!(:find).and_return(@patient)
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
  
    it "should find the patient requested" do
      Patient.should_receive(:find).and_return(@patient)
      do_get
    end
  
    it "should assign the found Patient for the view" do
      do_get
      assigns[:patient].should equal(@patient)
    end
  end

  describe "handling POST /patients" do

    before(:each) do
      @patient = mock_model(Patient, :to_param => "1")
      Patient.stub!(:new).and_return(@patient)
    end
    
    describe "with successful save" do
  
      def do_post
        @patient.should_receive(:save).and_return(true)
        post :create, :patient => {}
      end
  
      it "should create a new patient" do
        Patient.should_receive(:new).with({}).and_return(@patient)
        do_post
      end

      it "should redirect to the new patient" do
        do_post
        response.should redirect_to(patient_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @patient.should_receive(:save).and_return(false)
        post :create, :patient => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /patients/1" do

    before(:each) do
      @patient = mock_model(Patient, :to_param => "1")
      Patient.stub!(:find).and_return(@patient)
    end
    
    describe "with successful update" do

      def do_put
        @patient.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the patient requested" do
        Patient.should_receive(:find).with("1").and_return(@patient)
        do_put
      end

      it "should update the found patient" do
        do_put
        assigns(:patient).should equal(@patient)
      end

      it "should assign the found patient for the view" do
        do_put
        assigns(:patient).should equal(@patient)
      end

      it "should redirect to the patient" do
        do_put
        response.should redirect_to(patient_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @patient.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /patients/1" do

    before(:each) do
      @patient = mock_model(Patient, :destroy => true)
      Patient.stub!(:find).and_return(@patient)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the patient requested" do
      Patient.should_receive(:find).with("1").and_return(@patient)
      do_delete
    end
  
    it "should call destroy on the found patient" do
      @patient.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the patients list" do
      do_delete
      response.should redirect_to(patients_url)
    end
  end
end