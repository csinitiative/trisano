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

describe DashboardController do

  describe "handling GET /dashboard" do
    
    before(:each) do
      mock_user
    end
    
    def do_get
      get :index
    end

    describe 'with filter applied' do
      
      before(:each) do
        @controller.expects(:has_a_filter_applied?).returns(true)
        # Test used to use #an_instance_of? but that failed in 1.1.12.  See here: http://rubyforge.org/frs/shownotes.php?release_id=30324
        User.current_user.expects(:store_as_task_view_settings).with(kind_of(Hash))
      end

      it "should be successful" do
        do_get
        response.should be_success
      end
    
      it "should render index template" do
        do_get
        response.should render_template('index')
      end
    
      it "should assign a user" do
        do_get
        User.current_user.nil?.should be_false
      end
    end

    describe 'with no filter applied' do
      before(:each) do
        @controller.expects(:has_a_filter_applied?).returns(false)
        @user.expects(:task_view_settings).returns({:look_ahead => '0', :look_back => '0'})
      end

      it 'should redirect to dashboard with default filters applied' do
        do_get
        response.should redirect_to('/?look_ahead=0&look_back=0')
      end
    end

  end
 
  describe "handling GET /dashboard with no logged in user" do
    before(:each) do
      controller.session[:user_id] = ''
    end
    
    it "should redirect to 500 error page" do
      get :index
      response.response_code.should == 403
    end
    
  end

  describe "#has_filter_applied?" do
    it 'should be true if :look_ahead is a parameter' do
      @controller.send(:has_a_filter_applied?, :look_ahead => '1').should be_true
    end

    it 'should be true if :look_back is a parameter' do
      @controller.send(:has_a_filter_applied?, :look_back => '1').should be_true
    end

    it 'should return false unless :look_ahead or :look_back is present' do
      @controller.send(:has_a_filter_applied?, {}).should be_false
    end
  end
end
