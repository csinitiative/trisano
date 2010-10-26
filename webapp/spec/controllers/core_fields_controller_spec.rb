# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
    include DiseaseSpecHelper

    before do
      @lycanthropy = given_a_disease_named('Lycanthropy')
      @vampirism = given_a_disease_named('Vampirism')
      mock_user
    end

    it "returns a 404 if the disease is missing" do
      post :apply_to
      response.code.should == "405"
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

end

