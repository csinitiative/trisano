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

describe UserTasksController do
  before do
    mock_user = Factory.build(:user)
    mock_user.stubs(:is_entitled_to?).returns(true)
    User.stubs(:current_user).returns(mock_user)
  end

  describe "handling ajax GET /user/1/tasks" do

    def do_xhr
      user = mock('mock user')
      controller.expects(:load_user)
      controller.expects(:find_user)
      xhr :get, :index
    end

    it 'should respond to xhr requests' do
      do_xhr
      response.should be_success
    end

    it 'should render the list tasks partial' do
      do_xhr
      response.should render_template('tasks/_list.html.haml')
    end

  end

  describe "handling ajax PUT /user/1/tasks/1" do
    def do_put
      @user  = mock('user')
      @tasks = mock('tasks')
      @task  = mock('task')
      @user.expects(:tasks).returns(@tasks)
      @tasks.expects(:find).returns(@task)
      @task.expects(:update_attributes).returns(true)
      controller.expects(:load_user)
      User.stubs(:find).returns(@user)
      put :update, :task => {}
    end

    it "should find the task requested" do
      do_put
    end

    it "should render 'update'" do
      do_put
      response.should render_template('update')
    end

    it "should set the flash notice to a success message" do
      do_put
      flash[:notice].should eql("Task was successfully updated.")
    end

  end
end

