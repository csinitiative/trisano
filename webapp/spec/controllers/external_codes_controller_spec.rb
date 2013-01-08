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
require 'spec_helper'

describe ExternalCodesController do
  fixtures :code_names

  before do
    mock_user
  end

  it "returns external codes codes by code name" do
    lambda { get 'index_code', :code_name => 'race' }.should_not raise_error
    response.should be_success
    assigns[:external_codes].should_not be_nil
  end

  it "returns external codes as xml" do
    lambda do
      request.env['HTTP_ACCEPT'] = 'application/xml'
      get 'index_code', :code_name => 'race'
    end.should_not raise_error
    response.should be_success
    response.content_type.should == 'application/xml'
  end
end
