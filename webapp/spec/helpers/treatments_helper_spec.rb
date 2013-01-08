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

describe TreatmentsHelper do

  describe "#treatment_status text" do
    before do
      @treatment = Factory(:treatment)
    end

    it "returns 'Active' if treatment is active" do
      helper.treatment_status(@treatment).should == "Active"
    end

    it "returns 'Inactive Default' if treatment is not active and default" do
      @treatment.active = false
      @treatment.default = true
      helper.treatment_status(@treatment).should == "Inactive&nbsp;Default"
    end

    it "returns 'Active Default' if treatment is active and default" do
      @treatment.default = true
      helper.treatment_status(@treatment).should == "Active&nbsp;Default"
    end
  end

end
