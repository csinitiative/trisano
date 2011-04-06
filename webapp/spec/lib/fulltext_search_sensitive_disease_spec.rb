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

describe "searching with sensitive diseases" do

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  describe "excluding sensitive diseases based on role" do
    
    before(:each) do
      @sensitive_disease_jurisdiction = create_jurisdiction_entity(:place => Factory.create(:place, :name => 'Bear Cub River'))
      @sensitive_disease_role = create_role_with_privileges!('sensitive_disease_role', :access_sensitive_diseases)
      @sensitive_disease_user = create_user_in_role!(@sensitive_disease_role.role_name, 'Bobby Johanssenson')
      @sensitive_disease_user.reload

      @not_sensitive_disease_user = Factory.create(:user)

      @sensitive_disease = Factory.create(:disease, :disease_name => 'AIDS', :sensitive => true)
      @not_sensitive_disease = Factory.create(:disease, :disease_name => 'African Tick Bite Fever', :sensitive => false)
      @not_sensitive_event = searchable_event!(:morbidity_event, 'James')
      
      @sensitive_event = create_morbidity_event(
        :patient => "James",
        :disease => @sensitive_disease,
        :jurisdiction => @sensitive_disease_jurisdiction
      )
    end

    it "should include all events for a user with sensitive disease privileges" do
      User.current_user = @sensitive_disease_user
    end

  end

end


