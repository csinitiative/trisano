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

require File.dirname(__FILE__) + '/../../../spec_helper'
require 'trisano/cucumber/profiles'

include Trisano::Cucumber

describe Profiles do

  before do
    @profiles = Profiles.new
    @base_config = {
      'standard' => 'features/standard -r features/support -r features/steps --tags ~pending',
      'enhanced' => 'features/enhanced -r features/support -r features/enhanced_steps --tags ~pending'}
    @profiles.merge!(@base_config)
  end

  it "should merge w/ hashes" do
    @profiles.each do |profile, command|
      @base_config[profile].should == command
    end

    @profiles.count.should == @base_config.count
  end

  it "should return a profile by name" do
    @profiles['standard'].should == 'features/standard -r features/support -r features/steps --tags ~pending'
  end

  describe "merging" do
    before do
      @more_standard = {'standard' => 'vendor/plugins/something/features -r vendor/plugins/something/features/support --tags wip'}
      @expected = 'features/standard -r features/support -r features/steps --tags ~pending vendor/plugins/something/features -r vendor/plugins/something/features/support --tags wip'
    end

    it "should munge values together, rather then replace values" do
      @profiles.merge!(@more_standard)
      @profiles['standard'].should == @expected
    end

    it "should support partial merges" do
      @profiles.merge!('standard' => '--tags @wip')
      @profiles['standard'].should == 'features/standard -r features/support -r features/steps --tags ~pending --tags @wip'
    end
  end

end
