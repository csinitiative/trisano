# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe CoreFieldsDisease, "in the Perinatal Hep B plugin" do
  include DiseaseSpecHelper
  include PerinatalHepBSpecHelper

  describe "creating default associations" do
    before do
      given_a_disease_named('Hepatitis B Pregnancy Event')
      given_p_hep_b_core_fields_loaded
      given_ce_core_fields_to_replace_loaded
    end

    it "should associate hep b core fields w/ acute Hep B" do
      lambda do
        CoreFieldsDisease.create_perinatal_hep_b_associations
      end.should change(CoreFieldsDisease, :count).by(@core_fields.size + @replacement_core_fields.size)
      Disease.find_by_disease_name('Hepatitis B Pregnancy Event').core_fields.size.should == @core_fields.size + @replacement_core_fields.size
    end

  end

end
