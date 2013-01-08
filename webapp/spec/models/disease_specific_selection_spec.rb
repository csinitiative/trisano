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

describe DiseaseSpecificSelection do

  it { should belong_to(:disease) }
  it { should belong_to(:external_code) }

  it { should validate_presence_of(:disease_id) }
  it { should validate_presence_of(:external_code_id) }

  it "should create a new instance based on an search conditions" do
    disease = disease!('The Trots')
    code = external_code!('toilet_paper_type', 'C', :code_description => 'Coarse')
    disease_conditions = { 'disease' => { 'disease_name' => 'The Trots' } }
    external_code_conditions = {
      'external_code' => {
        'code_name' => 'toilet_paper_type',
        'the_code' => 'C'
      }
    }
    lambda do
      DiseaseSpecificSelection.load! [ disease_conditions.merge(external_code_conditions) ]
    end.should change(DiseaseSpecificSelection, :count).by(1)
    code.disease_specific_selections.map(&:disease_id).should == [disease.id]
  end

end
