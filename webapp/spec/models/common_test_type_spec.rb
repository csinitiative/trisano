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

describe CommonTestType do
  fixtures :external_codes, :common_test_types

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  describe 'associations' do
    it { should have_many(:common_test_types_diseases) }
    it { should have_many(:diseases) }
    it { should have_many(:loinc_codes) }
    it { should have_many(:lab_results) }
  end

  before do
    @common_test_type = CommonTestType.find_or_create_by_common_name('Culture')
  end

  it "should be able to bulk load from a csv format" do
    lambda do
      CommonTestType.load_from_csv <<CSV
"Aztreonam susceptibility"
"Beta lactamase extended spectrum susceptibility"
"Beta lactamase susceptibility"
CSV
    end.should change(CommonTestType, :count).by(3)
  end

  describe 'updating loinc codes' do

    before do
      @loinc_code = LoincCode.create!(:loinc_code => '636-9',
                                      :scale_id => external_codes(:loinc_scale_ord).id)
    end

    it 'should be able to add loinc codes by id' do
      @common_test_type.loinc_codes.should == []
      @common_test_type.update_loinc_code_ids :add => [@loinc_code.id.to_s]
      @common_test_type.loinc_codes.should == [@loinc_code]
      lambda{ @common_test_type.update_loinc_code_ids :add => [@loinc_code.id.to_s] }.should_not raise_error
    end

    it 'should not raise an error if a loinc code is added more then once' do
      @common_test_type.update_loinc_code_ids :add => [@loinc_code.id.to_s]
      @common_test_type.loinc_codes.should == [@loinc_code]
      lambda{@common_test_type.update_loinc_code_ids :add => [@loinc_code.id.to_s] }.should_not raise_error
      @common_test_type.loinc_codes.should == [@loinc_code]
    end

    it 'will overwrite add operations with remove operations' do
      @common_test_type.update_loinc_code_ids :add => [@loinc_code.id.to_s], :remove => [@loinc_code.id.to_s]
      @common_test_type.loinc_codes.should == []
    end

  end

  describe 'common name' do

    it 'should be unique' do
      CommonTestType.create :common_name => 'Doit'
      lambda {CommonTestType.create! :common_name => 'Doit'}.should raise_error
      CommonTestType.new(:common_name => 'Doit').should_not be_valid
    end

    it 'should be case fold unique' do
      CommonTestType.create :common_name => 'DOIT'
      lambda {CommonTestType.create! :common_name => 'doit'}.should raise_error
      CommonTestType.new(:common_name => 'Doit').should_not be_valid
    end

    it 'should not be null' do
      lambda {CommonTestType.create!}.should raise_error
      CommonTestType.new.should_not be_valid
    end

    it 'should not be longer then 255 chars' do
      CommonTestType.new(:common_name => ('c' * 256)).should_not be_valid
      CommonTestType.new(:common_name => ('c' * 255)).should be_valid
    end

    it 'should be destroyed' do
      lambda do
        @common_test_type.destroy
      end.should change(CommonTestType, :count).by(-1)
    end

  end

  describe 'that is associated with a lab result' do
    before do
      @lab_result = Factory.create(:lab_result, :test_type_id => @common_test_type.id)
    end

    it 'should not be destroyed' do
      lambda { @common_test_type.destroy }.should raise_error
    end
  end

  describe 'with associated loinc codes' do
    before do
      @loinc_codes = []
      @loinc_codes << LoincCode.create!(:loinc_code => '14375-1',
                                        :test_name => 'Nulla felis nibh, aliquet eget, Unspecified',
                                        :common_test_type_id => @common_test_type.id,
                                        :scale_id => external_codes(:loinc_scale_ord).id)
      @loinc_codes << LoincCode.create!(:loinc_code => '636-3',
                                        :test_name => 'Culture, Sterile body fluid',
                                        :common_test_type_id => @common_test_type.id,
                                        :scale_id => external_codes(:loinc_scale_ord).id)
    end

    it 'should remove loinc associations when destroyed' do
      @common_test_type.destroy
      LoincCode.find_all_by_common_test_type_id(@common_test_type.id).should == []
    end

    it 'should be able to remove loinc codes by id' do
      @common_test_type.loinc_codes.sort_by(&:id).should == @loinc_codes.sort_by(&:id)
      @common_test_type.update_loinc_code_ids :remove => @loinc_codes.collect { |c| c.id.to_s }
      @common_test_type.loinc_codes.should == []
    end

    it 'should be able to add and remove in same operation' do
      new_loinc = LoincCode.create :loinc_code => '636-9', :scale_id => external_codes(:loinc_scale_ord).id
      @common_test_type.update_loinc_code_ids(:add => [new_loinc.id.to_s],
                                              :remove => @loinc_codes.collect { |c| c.id.to_s })
      @common_test_type.loinc_codes.should == [new_loinc]
    end

  end

  describe 'with associated loinc codes and assoicated lab results' do
    before do
      @lab_result = Factory.create(:lab_result, :test_type_id => @common_test_type.id)
      @loinc_code = LoincCode.create!(:loinc_code => '636-3',
                                      :common_test_type_id => @common_test_type.id,
                                      :scale_id => external_codes(:loinc_scale_ord).id)
    end

    it 'should not clear loincs on a failed destroy' do
      lambda{ @common_test_type.destroy }.should raise_error
      LoincCode.find_all_by_common_test_type_id(@common_test_type.id).should == [@loinc_code]
    end

  end

end
