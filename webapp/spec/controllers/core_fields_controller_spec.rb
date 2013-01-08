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

describe CoreFieldsController do

  describe "handling an administrator's request" do
    before do
      mock_user
      get :index
    end

    it "returns successfully" do
      response.should be_success
    end

    it "renders the index view" do
      response.should render_template('index')
    end
  end

  describe "handling a request from an non-administrative user" do
    before do
      mock_user
      @user.stubs(:is_admin?).returns(false)
      get :index
    end

    it "forbids access" do
      response.response_code.should == 403
    end
  end

  describe "copying core field associations from one disease to another" do

    before do
      @lycanthropy = create_disease('Lycanthropy')
      @vampirism = create_disease('Vampirism')
      mock_user
    end

    it "returns a 404 if the disease is missing" do
      post :apply_to
      response.code.should == "404"
    end

    it "redirects to disease core fields index" do
      post :apply_to, :disease_id => @lycanthropy.id, :other_disease_ids => [@vampirism.id]
      response.should redirect_to(diseases_url)
    end

    it "displays a 'success' message if operation succeeds" do
      post :apply_to, :disease_id => @lycanthropy.id, :other_disease_ids => [@vampirism.id]
      flash[:notice].should == 'Core fields successfully copied'
    end

    it "displays an 'error' message if operation fails" do
      post :apply_to, :disease_id => @lycanthropy.id, :other_disease_ids => nil
      flash[:error].should == 'No diseases were selected for update'
    end
  end

  describe "update /core_fields/:id" do

    before :all do
      given_core_fields_loaded_for :morbidity_event
    end

    before do
      @lycanthropy = create_disease('Lycanthropy')
      @core_field = CoreField.find_by_key('morbidity_event[parent_guardian]')
      mock_user
    end

    it "updates default core field settings" do
      put :update, :id => @core_field.id, :core_field => {:rendered_attributes => { :rendered => false } }
      assigns[:core_field].should == @core_field
      flash[:notice].should == 'Core field was successfully updated.'
      response.should redirect_to(core_field_path(@core_field))
    end

    it "renders a partial back for ajax requests" do
      xhr :put, :update, :id => @core_field.id, :core_field => { :rendered_attributes => { :rendered => false } }
      response.should render_template('core_fields/_core_field')
    end

    it "render updates the disease specific setting, if disease available" do
      CoreField.stubs(:find).returns(@core_field)
      @core_field.expects(:update_attributes).with('rendered_attributes' => { 'rendered' => 0, 'disease_id' => @lycanthropy.id }).returns(true)
      put :update, :id => @core_field.id, :disease_id => @lycanthropy.id, 'core_field' => { 'rendered_attributes' => { 'rendered' => 0 } }
      response.should redirect_to(disease_core_field_path(@lycanthropy, @core_field))
    end
  end
end

