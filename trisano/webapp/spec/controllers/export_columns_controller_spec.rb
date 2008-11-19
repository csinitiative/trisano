# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe ExportColumnsController do
  describe "handling GET /export_columns" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn)
      ExportColumn.stub!(:find).and_return([@export_column])
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
  
    it "should find all export columns" do
      ExportColumn.should_receive(:find).and_return([@export_column])
      do_get
    end
  
    it "should assign the found export columns for the view" do
      do_get
      assigns[:export_columns].should == [@export_column]
    end
  end

  describe "handling GET /export_columns/1" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn)
      ExportColumn.stub!(:find).and_return(@export_column)
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
  
    it "should find the export_column requested" do
      ExportColumn.should_receive(:find).with("1").and_return(@export_column)
      do_get
    end
  
    it "should assign the found export_column for the view" do
      do_get
      assigns[:export_column].should equal(@export_column)
    end
  end

  describe "handling GET /export_columns/new" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn)
      ExportColumn.stub!(:new).and_return(@export_column)
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
  
    it "should create an new export_column" do
      ExportColumn.should_receive(:new).and_return(@export_column)
      do_get
    end
  
    it "should not save the new export_column" do
      @export_column.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new export_column for the view" do
      do_get
      assigns[:export_column].should equal(@export_column)
    end
  end

  describe "handling GET /export_columns/1/edit" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn)
      ExportColumn.stub!(:find).and_return(@export_column)
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
  
    it "should find the export_column requested" do
      ExportColumn.should_receive(:find).and_return(@export_column)
      do_get
    end
  
    it "should assign the found ExportColumn for the view" do
      do_get
      assigns[:export_column].should equal(@export_column)
    end
  end

  describe "handling POST /export_columns" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn, :to_param => "1")
      @export_column.stub!(:export_name=).and_return("CDC") 
      ExportColumn.stub!(:new).and_return(@export_column)
    end
    
    describe "with successful save" do
  
      def do_post
        @export_column.should_receive(:save).and_return(true)
        post :create, :export_column => {}
      end
  
      it "should create a new export_column" do
        ExportColumn.should_receive(:new).with({}).and_return(@export_column)
        do_post
      end

      it "should redirect to the new export_column" do
        do_post
        response.should redirect_to(export_column_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @export_column.should_receive(:save).and_return(false)
        post :create, :export_column => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /export_columns/1" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn, :to_param => "1")
      ExportColumn.stub!(:find).and_return(@export_column)
    end
    
    describe "with successful update" do

      def do_put
        @export_column.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the export_column requested" do
        ExportColumn.should_receive(:find).with("1").and_return(@export_column)
        do_put
      end

      it "should update the found export_column" do
        do_put
        assigns(:export_column).should equal(@export_column)
      end

      it "should assign the found export_column for the view" do
        do_put
        assigns(:export_column).should equal(@export_column)
      end

      it "should redirect to the export_column" do
        do_put
        response.should redirect_to(export_column_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @export_column.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /export_columns/1" do

    before(:each) do
      mock_user
      @export_column = mock_model(ExportColumn, :destroy => true)
      ExportColumn.stub!(:find).and_return(@export_column)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the export_column requested" do
      ExportColumn.should_receive(:find).with("1").and_return(@export_column)
      do_delete
    end
  
    it "should call destroy on the found export_column" do
      @export_column.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the export columns list" do
      do_delete
      response.should redirect_to(export_columns_url)
    end
  end
end
