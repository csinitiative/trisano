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

describe ExportConversionValuesController do
  before(:each) do
    mock_user
    @proxy = mock('proxy')
    @export_column = Factory.create(:export_column)
    @export_column.stubs(:export_conversion_values).returns(@proxy)
    ExportColumn.stubs(:find).returns(@export_column)
  end

  describe "handling GET /export_conversion_values" do

    def do_get
      get :index, :export_column_id => "1"
    end

    it "should redirect to the parent export_column" do
      do_get
      response.should redirect_to(export_column_url(@export_column.id))
    end

  end

  describe "handling GET /export_conversion_values/1" do

    def do_get
      get :show, :id => "1", :export_column_id => "1"
    end

    it "should redirect to the parent export_column" do
      do_get
      response.should redirect_to(export_column_url(@export_column.id))
    end

  end

  describe "handling GET /export_conversion_values/new" do

    before(:each) do
      @export_conversion_value = Factory.create(:export_conversion_value)
      ExportConversionValue.stubs(:new).returns(@export_conversion_value)
    end

    def do_get
      get :new, :export_column_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should create an new export_conversion_value" do
      ExportConversionValue.expects(:new).returns(@export_conversion_value)
      do_get
    end

    it "should not save the new export_conversion_value" do
      @export_conversion_value.expects(:save).never
      do_get
    end

    it "should assign the new export_conversion_value for the view" do
      do_get
      assigns[:export_conversion_value].should equal(@export_conversion_value)
    end
  end

  describe "handling GET /export_conversion_values/1/edit" do

    before(:each) do
      @export_conversion_value = Factory.create(:export_conversion_value)
      @proxy.stubs(:find).returns(@export_conversion_value)
    end

    def do_get
      get :edit, :id => "1", :export_column_id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end

    it "should find the export_conversion_value requested" do
      @proxy.expects(:find).with("1").returns(@export_conversion_value)
      do_get
    end

    it "should assign the found ExportConversionValue for the view" do
      do_get
      assigns[:export_conversion_value].should equal(@export_conversion_value)
    end
  end

  describe "handling POST /export_conversion_values" do

    before(:each) do
      @export_conversion_value = Factory.create(:export_conversion_value)
      @export_conversion_value.stubs(:export_name=).returns("CDC")
    end

    describe "with successful save" do

      def do_post
        @proxy.expects(:<<).returns(true)
        post :create, :export_conversion_value => {}, :export_column_id => "1"
      end

      it "should create a new export_conversion_value" do
        ExportConversionValue.expects(:new).with({}).returns(@export_conversion_value)
        do_post
      end

      it "should redirect to the parent export_column" do
        do_post
        response.should redirect_to(export_column_url(@export_column.id))
      end

    end

    describe "with failed save" do

      def do_post
        @proxy.expects(:<<).returns(false)
        post :create, :export_conversion_value => {}, :export_column_id => "1"
      end

      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /export_conversion_values/1" do

    before(:each) do
      @export_conversion_value = Factory.create(:export_conversion_value)
      @proxy.stubs(:find).returns(@export_conversion_value)

    end

    describe "with successful update" do

      def do_put
        @export_conversion_value.expects(:update_attributes).returns(true)
        put :update, :id => "1", :export_column_id => "1"
      end

      it "should find the export_conversion_value requested" do
        @proxy.expects(:find).with("1").returns(@export_conversion_value)
        do_put
      end

      it "should update the found export_conversion_value" do
        do_put
        assigns(:export_conversion_value).should equal(@export_conversion_value)
      end

      it "should assign the found export_conversion_value for the view" do
        do_put
        assigns(:export_conversion_value).should equal(@export_conversion_value)
      end

      it "should redirect to the export_conversion_value" do
        do_put
        response.should redirect_to(export_column_url(@export_column.id))
      end

    end

    describe "with failed update" do

      def do_put
        @export_conversion_value.expects(:update_attributes).returns(false)
        put :update, :id => "1", :export_column_id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /export_conversion_values/1" do

    before(:each) do
      mock_user
      @export_conversion_value = Factory.build(:export_conversion_value)
      @proxy.stubs(:find).returns(@export_conversion_value)
      @proxy.stubs(:delete).returns(true)
    end

    def do_delete
      delete :destroy, :id => "1", :export_column_id => "1"
    end

    it "should find the export_conversion_value requested" do
      @proxy.expects(:find).with("1").returns(@export_conversion_value)
      do_delete
    end

    it "should call destroy on the found export_conversion_value" do
      @proxy.expects(:delete)
      do_delete
    end

    it "should redirect to the export conversion value list" do
      do_delete
      response.should redirect_to(export_column_url(@export_column.id))
    end
  end
end
