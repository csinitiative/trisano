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

describe TreatmentsController do

  before do
    mock_user
    @treatment_1 = Factory(:treatment)
    @treatment_2 = Factory(:treatment)
  end

  describe "/treatments" do
    it "renders the index template" do
      get :index
      response.should be_success
      response.should render_template('index')
    end

    it "includes all treatments, by default" do
      get :index
      assigns[:treatments].should == [@treatment_1, @treatment_2]
    end
  end

  describe "/diseases/:disease_id/treatments" do
    before do
      @disease = Factory(:disease)
    end

    it "renders the disease treatments index template" do
      get :index, :disease_id => @disease.id
      response.should be_success
      response.should render_template('/diseases/treatments/index')
    end

    it "displays all treatments, by default" do
      get :index
      assigns[:treatments].should == [@treatment_1, @treatment_2]
    end

    it "excludes treatments from results if they're already associated w/ the disease" do
      @disease.add_treatments([@treatment_1.id])
      get :index, :disease_id => @disease.id
      assigns[:treatments].should == [@treatment_2]
    end
  end

  describe "/associate" do
    it "returns :not_found" do
      post :associate
      response.code.should == "404"
    end
  end

  describe "diseases/:disease_id/associate" do
    before do
      @disease = Factory(:disease)
      Disease.expects(:find).with(@disease.id.to_s).returns(@disease)
    end

    it "should redirect back to disease treatment index on success" do
      @disease.expects(:add_treatments).returns(true)
      post :associate, :disease_id => @disease.id
      response.should redirect_to(disease_treatments_url(@disease))
    end

    it "adds associations to @disease" do
      @disease.expects(:add_treatments).with(%w(1 3)).returns(true)
      post :associate, :disease_id => @disease.id, :associations => %w(1 3)
    end

    it "displays success messages in flash :notice" do
      @disease.expects(:add_treatments).returns(true)
      post :associate, :disease_id => @disease.id
      flash[:notice].should == "Disease treatments updated"
    end

    it "displays failure messages in flash :error" do
      @disease.expects(:add_treatments).returns(false)
      post :associate, :disease_id => @disease.id
      flash[:error].should == "Update failed. Please try again or contact your administrator."
    end
  end

  describe "/disassociate" do
    it "returns :not_found" do
      post :disassociate
      response.code.should == "404"
    end
  end

  describe "/diseases/:disease_id/disassociate" do
    before do
      @disease = Factory(:disease)
      Disease.expects(:find).with(@disease.id.to_s).returns(@disease)
    end

    it "removes treatment associations from @disease" do
      @disease.expects(:remove_treatments).with(%w(1 3)).returns(true)
      post :disassociate, :disease_id => @disease.id, :associations => %w(1 3)
    end

    it "redirects back to the disease treatment index page" do
      post :disassociate, :disease_id => @disease.id
      response.should redirect_to(disease_treatments_url(@disease))
    end

    it "puts success messages in flash :notice" do
      @disease.expects(:remove_treatments).returns(true)
      post :disassociate, :disease_id => @disease.id
      flash[:notice].should == "Disease treatments updated"
    end

    it "puts failure messages in flash :error" do
      @disease.expects(:remove_treatments).returns(false)
      post :disassociate, :disease_id => @disease.id
      flash[:error].should == "Update failed. Please try again or contact your administrator."
    end
  end

  describe "/apply_to" do
    it "returns :not_found" do
      post :apply_to
      response.code.should == "404"
    end
  end

  describe "/diseases/:disease_id/apply_to" do
    before do
      @disease = Factory(:disease)
      Disease.expects(:find).with(@disease.id.to_s).returns(@disease)
    end

    it "applies treatment-to-disease associations to other diseases, by id" do
      @disease.expects(:apply_treatments_to).with(%w(101 103)).returns(true)
      post :apply_to, :disease_id => @disease.id, :other_disease_ids => %w(101 103)
    end

    it "redirects to the disease treatments listing on failure" do
      @disease.expects(:apply_treatments_to).returns(false)
      post :apply_to, :disease_id => @disease.id
      response.should redirect_to(disease_treatments_url(@disease))
    end

    it "redirects to disease treatments listing on success" do
      @disease.expects(:apply_treatments_to).returns(true)
      post :apply_to, :disease_id => @disease.id
      response.should redirect_to(disease_treatments_url(@disease))
    end

    it "displays success messages in flash :notice" do
      @disease.expects(:apply_treatments_to).returns(true)
      post :apply_to, :disease_id => @disease.id
      flash[:notice].should == 'Disease treatments copied'
    end

    it "displays failure messages in flash :error" do
      @disease.expects(:apply_treatments_to).returns(false)
      post :apply_to, :disease_id => @disease.id
      flash[:error].should == "Update failed. Please try again or contact your administrator."
    end
  end
end
