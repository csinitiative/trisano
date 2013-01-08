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

describe Entity, "associations" do
  # TGRII: Not working for reasons unknown.  There's something funny about participations
  # it { should have_one(:participation) }
  it { should have_many(:telephones) }
  it { should have_many(:email_addresses) }
  it { should have_many(:addresses) }
  it { should have_one(:canonical_address) }
end

describe Entity, "nested attributes are assigned" do
  it { should accept_nested_attributes_for(:canonical_address ) }
end
