# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../spec_helper'

describe LibraryElementsController do

  describe "handling GET /library_elements" do

    before(:each) do
      mock_user
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
  
  end

  describe "handling GET /library_elements/1" do

    before(:each) do
      mock_user
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
  
  end

  describe "handling GET /library_elements/new" do

    before(:each) do
      mock_user
    end
  
    def do_get
      get :new
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
    
  end

  describe "handling GET /library_elements/1/edit" do

    before(:each) do
      mock_user
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should return a 405" do
      do_get
      response.response_code.should == 405
    end
    
  end

  describe "handling POST /library_elements" do

    before(:each) do
      mock_user
    end
    
    describe "with save" do
      def do_post
        post :create, :import => {}
      end
  
      it "should return a 405" do
        do_post
        response.response_code.should == 405
      end
    end

  end

  describe "handling PUT /library_elements/1" do

    before(:each) do
      mock_user
    end
    
    describe "with update" do
      def do_put
        put :update, :id => "1", :import => {}
      end

      it "should return a 405" do
        do_put
        response.response_code.should == 405
      end
    end

  end

  describe "handling DELETE /library_elements/1" do

    before(:each) do
      mock_user
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should return a 405" do
      do_delete
      response.response_code.should == 405
    end
    
  end
  

  describe "handling POST /library_elements/export" do

    describe 'on successful export' do

      before :each do
        mock_user
      end

      def do_post
        post :export
      end

      it 'should send export file' do
        Form.expects(:export_library).returns("library-export.zip")
        @controller.expects(:send_file).with("library-export.zip")
        do_post
        response.should be_success
      end

    end

    describe 'on failed export' do
    
      before :each do
        mock_user
      end
    
      def do_post
        post :export
      end
    
      it 'should redirect to library_elements listing' do
        Form.expects(:export_library).raises(Exception)
        @controller.expects(:send_file).with(("library-export.zip")).never
        do_post
        response.should redirect_to(library_elements_path)
      end
    
    end

  end
  
  describe "handling POST /library_elements/import" do
  
    describe 'when lacking upload file' do
  
      before :each do
        mock_user
      end
  
      def do_post
        post :import, :import => ""
      end
  
      it 'should re-render index' do
        do_post
        response.should render_template :index
      end

      it 'should set a flash message' do
        do_post
        flash[:error].should eql("Please navigate to a library export file to import.")
      end
  
    end
    
    describe 'on successful import' do

      before :each do
        mock_user
        @upload_file = mock('ActionController::UploadedStringIO')
      end

      def do_post
        post :import, :import => @upload_file
      end

      it 'should be successful' do
        Form.expects(:import_library).returns(true)
        do_post
        response.should redirect_to(library_elements_path)
      end
      
      it 'should set a flash message' do
        Form.expects(:import_library).returns(true)
        do_post
        flash[:notice].should eql('Successfully imported the library elements.')
      end

    end
    
    describe 'on failed import' do

      before :each do
        mock_user
        Form.stubs(:import_library).raises(Exception)
        @upload_file = mock('ActionController::UploadedStringIO')
      end

      def do_post
        post :import, :import => @upload_file
      end

      it 'should redirect to library_elements listing' do
        do_post
        response.should redirect_to(library_elements_path)
      end

    end
  end
  
end
