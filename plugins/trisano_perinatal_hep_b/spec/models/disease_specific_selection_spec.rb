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

describe DiseaseSpecificSelection, "in the Perinatal Hep B plugin" do

  before do
    create_disease('Hepatitis B Pregnancy Event')
    given_contact_disposition_type_codes_loaded
    given_contact_type_codes_loaded
    given_race_codes_loaded
    given_hep_b_external_codes_loaded
  end

  it "should associate hep b specific external codes for hep b selections based on disease" do
    lambda do
      DiseaseSpecificSelection.create_perinatal_hep_b_associations
    end.should change(DiseaseSpecificSelection, :count).by(35)
  end

end
