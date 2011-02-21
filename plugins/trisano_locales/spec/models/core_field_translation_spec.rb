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

describe CoreFieldTranslation do

  before do
    @cf = Factory.create(:cmr_core_field)
  end

  it "belongs to a core field" do
    should belong_to(:core_field)
  end

  it "allows only one entry, per core field id, per locale" do
    first = CoreFieldTranslation.create!(:core_field_id => @cf.id, :locale => 'en')
    copy = first.clone
    copy.save
    copy.errors.on(:core_field_id).should == 'has already been taken'
  end

  it "requires a locale" do
    cft = CoreFieldTranslation.create(:core_field_id => @cf.id)
    cft.errors.on(:locale).should == "can't be blank"
  end

  it "require a core field id" do
    cft = CoreFieldTranslation.create(:locale => 'en')
    cft.errors.on(:core_field_id).should == "can't be blank"
  end

end
