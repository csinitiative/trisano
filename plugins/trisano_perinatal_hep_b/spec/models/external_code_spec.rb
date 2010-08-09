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

require File.expand_path(File.dirname(__FILE__) +  '/../../../../../spec/spec_helper')

describe ExternalCode, "in the Perinatal Hep B plugin" do

  describe "returning infant contact type" do

    before(:each) do
      @infant_contact_type_code = ExternalCode.find(:first, :conditions => "code_name = 'contact_type' and the_code = 'INFANT'")
      @infant_contact_type_code = Factory.create(:external_code, :code_name => 'contact_type', :the_code => 'INFANT') if @infant_contact_type_code.nil?
    end

    it "should find the infant contact type" do
      ExternalCode.infant_contact_type.id.should == @infant_contact_type_code.id
    end
  end
end
