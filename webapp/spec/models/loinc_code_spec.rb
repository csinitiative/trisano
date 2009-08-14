# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe LoincCode do
  fixtures :external_codes

  before do
    @scale = external_codes :loinc_scale_ord
  end

  it 'scale and loinc code values should not be nil' do
    LoincCode.create.errors.on(:loinc_code).should be_true
    LoincCode.create.errors.on(:scale_id).should be_true
  end

  describe 'loinc code' do

    it 'should be unique' do
      LoincCode.create :loinc_code => '999999-9', :scale_id => @scale.id
      LoincCode.create(:loinc_code => '999999-9').errors.on(:loinc_code).should == "has already been taken"
      LoincCode.create(:loinc_code => '888888-8').errors.on(:loinc_code).should be_nil
    end

    it 'should not be longer then 10 chars' do
      LoincCode.create(:loinc_code => ('c' * 11)).errors.on(:loinc_code).should be_true
      LoincCode.create(:loinc_code => ('c' * 10)).errors.on(:loinc_code).should be_nil
    end

  end

  describe 'test name' do

    it 'should not be longer then 255 chars' do
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 256)).errors.on(:test_name).should be_true
      LoincCode.create(:loinc_code => '999999-9', :test_name => ('c' * 255)).errors.on(:test_name).should be_nil
    end

  end

  describe 'associations' do

    it { should belong_to(:common_test_type) }
    it { should have_many(:disease_common_test_types) }
    it { should have_many(:diseases) }

  end
end
