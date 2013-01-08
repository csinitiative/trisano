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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CoreFieldsDisease do

  it { should belong_to(:disease) }
  it { should belong_to(:core_field) }

  it "requires a disease" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:disease).should == "can't be blank"
  end

  it "requires a core field" do
    cfd = CoreFieldsDisease.create
    cfd.errors.on(:core_field).should == "can't be blank"
  end

  describe "creating associations" do

    before do
      @disease_name = "African Tick Bite Fever"
      create_disease(@disease_name)
      given_core_fields_loaded
      @fields = YAML::load_file(File.join(File.dirname(__FILE__), '../../db/defaults/core_fields.yml'))
    end

    it "should associate core fields, by key, with diseases, by name" do
      lambda do
        CoreFieldsDisease.create_associations(@disease_name, @fields)
      end.should change(CoreFieldsDisease, :count).by(@fields.size)
      Disease.find_by_disease_name(@disease_name).core_fields.size.should == @fields.size
    end

  end

end
