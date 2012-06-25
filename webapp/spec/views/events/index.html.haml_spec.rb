# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

require 'spec_helper'

describe "events/index.html.haml" do

  context "change view" do
    before :all do
      @user = Factory(:user)
      @sensitive_disease = Factory(:disease, :active => true, :sensitive => true)
      @normal_disease = Factory(:disease, :active => true, :sensitive => false)
    end

    before do
      User.current_user = @user
      assigns[:events] = [].paginate(:page => 1, :per_page => 10)
      assigns[:event_queues] = []
      assigns[:event_states_and_descriptions] = Event.get_all_states_and_descriptions
    end

    it "should not show sensitive diseases to users who don't have that privilege" do
      render "events/index.html.haml"
      response.should have_tag('#change_view') do
        with_tag('option', @normal_disease.disease_name)
        without_tag('option', @sensitive_disease.disease_name)
      end
    end

    it "should show sensitive diseases to users who have that privilege" do
      @user.stubs(:can_access_sensitive_diseases?).returns(true)
      render "events/index.html.haml"
      response.should have_tag('#change_view') do
        with_tag('option', @normal_disease.disease_name)
        with_tag('option', @sensitive_disease.disease_name)
      end
    end

    it "should show event queues for filtering" do
      event_queue = Factory :event_queue
      assigns[:event_queues] << event_queue
      render "events/index.html.haml"
      response.should have_tag('#change_view') do
        with_tag 'option', event_queue.name_and_jurisdiction
      end
    end
  end
end
