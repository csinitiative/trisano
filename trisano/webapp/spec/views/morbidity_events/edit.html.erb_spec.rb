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

require File.dirname(__FILE__) + '/../../spec_helper'

describe '/morbidity_events/edit.html.erb' do

  before(:each) do
    @user = mock_user
    User.stub!(:current_user).and_return(@user)
    @update_event = mock('update_event')
    @entitlements = mock('entitlements')
    @entitlements.stub!(:for_jurisdiction).and_return([])
    @update_event.stub!(:entitlements).and_return(@entitlements)
    Privilege.stub!(:update_event).and_return(@update_event)
    @event = MorbidityEvent.new_event_tree
    @event.parent_guardian = 'The State'

    assigns[:event] = @event
  end

  it 'should have parent/guardian field' do
    render '/morbidity_events/edit.html.erb'
    response.should have_tag('label', :text => 'Parent/Guardian')
    response.should have_tag('input#morbidity_event_parent_guardian')
  end

end
