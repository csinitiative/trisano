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

describe EventTypeTransition do

  let(:by) { Factory(:user) }
  let(:event) { Factory(:morbidity_event) }
  
  it "should record what type an event was, what it became, and who initiated the transition and when" do
    ett = EventTypeTransition.create(:event => event, :was => AssessmentEvent, :became => MorbidityEvent, :by => by)
    assert_equal event, ett.event
    assert_equal "AssessmentEvent", ett.was
    assert_equal "MorbidityEvent", ett.became
    assert_equal by, ett.by
    assert_not_equal nil, ett.created_at
  end

  it "should collect all transitions for event in the order which they were created" do
    contact_to_assessment = EventTypeTransition.create(:event => event, :was => ContactEvent, :became => AssessmentEvent, :by => by)
    assessment_to_morb = EventTypeTransition.create(:event => event, :was => AssessmentEvent, :became => MorbidityEvent, :by => by)
    assert_equal [contact_to_assessment, assessment_to_morb], EventTypeTransition.for(event)
  end
end

