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

describe Organism do

  it { should have_many(:loinc_codes) }
  it { should have_many(:diseases) }

  it 'has unique organism name (case insensitive)' do
    Organism.create(:organism_name => 'Arbovirus').errors.on(:organism_name).should == nil
    Organism.create(:organism_name => 'Arbovirus').errors.on(:organism_name).should == 'has already been taken'
    Organism.create(:organism_name => 'arbovirus').errors.on(:organism_name).should == 'has already been taken'
    Organism.create(:organism_name => ' Arbovirus ').errors.on(:organism_name).should == 'has already been taken'
  end

  it 'name cannot be blank' do
    Organism.create(:organism_name => '').errors.on(:organism_name).should == "can't be blank"
  end

  it "name can't be longer then 255 characters" do
    Organism.create(:organism_name => 'g' * 255).errors.on(:organism_name).should == nil
    Organism.create(:organism_name => 'f' * 256).errors.on(:organism_name).should == 'is too long (maximum is 255 characters)'
  end
end
