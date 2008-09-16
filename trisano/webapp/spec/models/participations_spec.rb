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

require File.dirname(__FILE__) + '/../spec_helper'

describe Participation do
  
  describe 'patient participation' do

    before :each do
      @pt = Participation.new_patient_participation
      @pt.save
    end

    it 'should be an interested party' do
      @pt.role_id.should == Code.interested_party.id
    end

    it 'should have a primary entity' do
      @pt.primary_entity.should_not be_nil
    end

    it 'should have an associated person through primary entity' do
      @pt.primary_entity.person_temp.should_not be_nil
    end

  end

end
    
    
