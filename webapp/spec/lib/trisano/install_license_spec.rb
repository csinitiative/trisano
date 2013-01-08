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
require 'lib/trisano'
require 'lib/trisano/install_license'
include Trisano::License

describe LicensedFile do

  describe "when license is present in position" do
    before do
      @license_text = "My fav license\n"
      @source = "My fav license\nalong with other source code"
      @licensed_file = LicensedFile.new(:license => @license_text, :source => @source, :position => :top)
    end

    it "can detect presence" do
      @licensed_file.license_present?.should be_true
    end

    it "can detect position" do
      @licensed_file.license_in_position?.should be_true
    end
    
    it "can decide if license_installed" do
      @licensed_file.license_installed?.should be_true
    end

    describe "update_source" do
      it "does not duplicate license when installing" do
        new_source = @licensed_file.update_source
        new_source.should be_equal(@source) 
      end
    end
  end


  describe "when license is present elsewhere" do
    before do
      @license_text = "My fav license\n"
      @source = "Some comments here\nMy fav license\nalong with other source code"
      @licensed_file = LicensedFile.new(:license => @license_text, :source => @source)
    end

    it "can detect presence" do
      @licensed_file.license_present?.should be_true
    end

    it "can detect position" do
      @licensed_file.license_in_position?.should be_false
    end

    it "can decide if license_installed" do
      @licensed_file.license_installed?.should be_false
    end


    describe "update_source" do
      it "moves license to position" do
        new_source = @licensed_file.update_source
        expected_source = @license_text + @source.sub(@license_text, "")
        new_source.should == expected_source
      end
    end
  end


  describe "when absent" do
    before do
      @license_text = "My fav license\n"
      @source = "My source code"
      @licensed_file = LicensedFile.new(:license => @license_text, :source => @source)
    end

    it "can detect presence" do
      @licensed_file.license_present?.should be_false
    end

    it "can detect position" do
      @licensed_file.license_in_position?.should be_false
    end

    it "can decide if license_installed" do
      @licensed_file.license_installed?.should be_false
    end

    describe "update_source" do
      it "returns new source with license installed" do
        new_source = @licensed_file.update_source
        expected_source = @license_text + @source.sub(@license_text,"")
        new_source.should == expected_source
      end
    end
  end
    
end
