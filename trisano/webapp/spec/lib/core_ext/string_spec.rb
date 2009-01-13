# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe 'to_soundex' do
  
  it 'should return nil for an empty string' do
    ''.to_soundex.should be_nil
  end

  it 'should treat upper and lower case equally' do
    'LOUD'.to_soundex.should == 'loud'.to_soundex
  end

  it 'should ignore non-alpha chars' do
    "O'Conner".to_soundex.should == 'oconner'.to_soundex
  end

  it 'should not return nil if str contains some non-alphas' do
    '999str_343'.to_soundex.should_not be_nil
  end

  it 'should return nil if entire string is non alpha' do
    "99_'-+345".to_soundex.should be_nil
  end
end
