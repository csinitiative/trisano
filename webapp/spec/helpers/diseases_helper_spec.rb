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

describe DiseasesHelper do

  before(:all) do
    destroy_fixture_data
  end

  after(:all){ Fixtures.reset_cache }

  it "#disease_check_boxes should style inactive diseases as inactive" do
    d1 = Factory.create(:disease, :active => true)
    d2 = Factory.create(:disease, :active => false)
    results = parse_html(helper.disease_check_boxes('foo'))
    results.xpath("//span[@class='inactive']").text.should == d2.disease_name
    results.xpath("//span[text()='#{d1.disease_name}']").attribute('class').should == nil
  end

  describe "#disease_tool_links" do

    before do
      @disease = Factory.create(:disease)
    end

    it "includes an edit link for the disease" do
      helper.disease_tool_links(@disease)[0].should == "<a href=\"/diseases/#{@disease.id}/edit\">Edit</a>"
    end

    it "includes a show link for the disease" do
      helper.disease_tool_links(@disease)[1].should == "<a href=\"/diseases/#{@disease.id}\">Show</a>"
    end

    it "includes a link to edit disease specific core fields" do
      helper.disease_tool_links(@disease)[2].should == "<a href=\"/diseases/#{@disease.id}/core_fields\">Core&nbsp;Fields</a>"
    end

    it "includes a link to edit disease specific treatment associations" do
      helper.disease_tool_links(@disease)[3].should == "<a href=\"/diseases/#{@disease.id}/treatments\">Treatments</a>"
    end
  end
end
