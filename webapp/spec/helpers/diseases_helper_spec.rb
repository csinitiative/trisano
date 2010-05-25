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

require File.dirname(__FILE__) + '/../spec_helper'

describe DiseasesHelper do
  include HtmlSpecHelper

  before(:all) do
    DiseaseEvent.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM diseases_export_columns;")
    Disease.delete_all
  end
  
  after(:all){ Fixtures.reset_cache }

  it "#disease_check_boxes should style inactive diseases as inactive" do
    d1 = Factory.create(:disease, :active => true)
    d2 = Factory.create(:disease, :active => false)
    results = parse_html(helper.disease_check_boxes('foo'))
    results.xpath("//span[@class='inactive']").text.should == d2.disease_name
    results.xpath("//span[text()='#{d1.disease_name}']").attribute('class').should == nil
  end

end
