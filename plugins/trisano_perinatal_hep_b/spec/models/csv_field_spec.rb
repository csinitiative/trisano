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

describe CsvField, "in the Perinatal Hep B plugin" do

  describe "creating CSV-field-to-core-field associations" do
    include PerinatalHepBSpecHelper

    before(:all) do
      given_p_hep_b_core_fields_loaded
      @csv_fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../config/misc/en_csv_fields.yml'))
      CsvField.load_csv_fields(@csv_fields)
    end

    it "should associate p-hep-b csv fields with core fields" do
      # Make sure some known p-hep-b CSV fields are not already associated with a core field
      CsvField.find(:all, :conditions => "long_name like '%delivery_facility%'").each do |field|
        field.disease_specific.should be_false
        field.core_field.should be_nil
      end

      CsvField.create_perinatal_hep_b_associations

      # Now they should be set
      CsvField.find(:all, :conditions => "long_name like '%delivery_facility%'").each do |field|
        field.disease_specific.should be_true
        field.core_field.should_not be_nil
      end
    end
  end

end
