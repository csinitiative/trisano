# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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
        @controller.should_receive(:has_a_filter_applied?).and_return(true)
        User.current_user.should_receive(:update_attribute).with(:task_view_settings, an_instance_of(Hash))
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
        @controller.should_receive(:has_a_filter_applied?).and_return(false)
      end

      describe 'and the user has no task view settings' do
        before(:each) do
          @user.should_receive(:has_task_view_settings?).and_return(false)
        end

        it "should be redirected" do          
          do_get
          response.should be_success
        end

      end

      describe 'and the user has task view settings' do
        before(:each) do
          @user.should_receive(:has_task_view_settings?).and_return(true)
          @user.should_receive(:task_view_settings).and_return({:look_ahead => '1'})
        end
        
        it 'should be redirected' do
          do_get
          response.should be_redirect
        end
        
        it 'should redirect to dashboard with filters applied' do
          do_get
          response.should redirect_to('/?look_ahead=1')
        end
      end
    end

  end
 
  describe "handling GET /dashboard with no logged in user" do
    before(:each) do
      controller.session[:user_id] = ''
    end
    
    it "should redirect to 500 error page" do
      get :index
      response.response_code.should == 500
    end
    
  end

  describe "handling ajax GET /dashboard" do
    
    def do_xhr
      user = mock('mock user')
      controller.should_receive(:load_user)
      User.should_receive(:current_user).and_return(user)
      xhr :get, :index
    end    

    it 'should respond to xhr requests' do
      do_xhr
      response.should be_success
    end

    it 'should render the list tasks partial' do
      do_xhr
      response.should render_template('event_tasks/_list.html.haml')
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
