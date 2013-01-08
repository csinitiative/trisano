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

describe SearchHelper do
  include Trisano::HTML::Matchers

  describe 'workflow_state_select_tag' do
    before do
      @workflow_state = mock('assigned', {
                               :description => 'Assigned to Investigator',
                               :workflow_state => :assigned })
      @workflow_states = [@workflow_state]
    end

    it "renders tag" do
      result = helper.workflow_states_select_tag(@workflow_states)
      result.should have_tag('select#workflow_state') do |select|
        select.should have_blank_option
        select.should have_option(:text => 'Assigned to Investigator',
                                  :value => 'assigned')
      end
    end

    it "renders tag w/ option selected" do
      result = helper.workflow_states_select_tag(@workflow_states, 'assigned')
      result.should have_tag('select#workflow_state') do |select|
        select.should have_blank_option
        select.should have_option(:text => 'Assigned to Investigator',
                                  :value => 'assigned',
                                  :selected => true)
      end
    end

  end

end
