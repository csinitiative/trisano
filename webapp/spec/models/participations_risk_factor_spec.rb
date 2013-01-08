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

describe ParticipationsRiskFactor do

  before do
    @event = Factory.create(:morbidity_event)
    @event.interested_party.risk_factor = @risk_factor
    @event.interested_party.save!
    @risk_factor = @event.interested_party.build_risk_factor
    @risk_factor.save!
  end

  it "should validate expected delivery date" do
    @risk_factor.should validate_date(:pregnancy_due_date)
  end

end
