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

describe DiseaseCommonTestType do
  fixtures :diseases, :common_test_types

  describe "associations" do

    it { should belong_to(:disease) }
    it { should belong_to(:common_test_type) }

  end

  it 'should not allow a association more then once' do
    d = DiseaseCommonTestType.create!(:disease_id => Disease.first.id, :common_test_type_id => CommonTestType.first.id)
    c = d.clone
    c.should_not be_valid
  end

end
