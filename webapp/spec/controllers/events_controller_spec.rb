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

require 'spec_helper'

describe EventsController do
  before do
    create_user
  end

  context "Adding a diagnostic facility search result to a cmr" do
    before do
      @place_entity = Factory.create(:place_entity)
    end

    it "renders diagnostic show partial" do
      get :diagnostics_search_selection, :id => @place_entity.id, :event_type => 'morbidity_event'
      response.should be_a_success
      response.should render_template 'events/_diagnostic'
    end
  end

  context "Using ajax to search for diagnosic facilities" do
    it "should render the diagnostics search partial" do
      get :diagnostic_facilities_search, :name => 'Example'
      response.should be_a_success
      response.should render_template('events/_diagnostics_search')
    end
  end

  context "Adding a reporting agency search result to a cmr" do
    before do
      @place_entity = Factory.create(:place_entity)
    end

    it "renders reporting agency partial" do
      get :reporting_agency_search_selection, :id => @place_entity.id, :event_type => 'morbidity_event'
      response.should be_a_success
      response.should render_template 'events/reporting_agency_search_selection.html.haml'
    end
  end

  context "Using ajax to search for reporting agencies" do
    it "should render the reporting agency search partial" do
      get :reporting_agencies_search, :name => 'Example', :event_type => 'morbidity_event'
      response.should be_a_success
      response.should render_template('events/_reporting_agencies_search')
    end
  end

end
