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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/core_fields/index.html.haml" do

  describe "with no @disease" do

    it "shows the help text area for regular fields" do
      assigns[:core_field] = Factory(:cmr_core_field)
      render '/core_fields/edit.html.haml'
      response.should have_tag('textarea#core_field_help_text')
    end

    it "doesn't show the help text area for sections" do
      assigns[:core_field] = Factory(:cmr_section_core_field)
      render '/core_fields/edit.html.haml'
      response.should_not have_tag('textarea#core_field_help_text')
    end

    it "doesn't show the help text area for tabs" do
      assigns[:core_field] = Factory(:cmr_tab_core_field)
      render '/core_fields/edit.html.haml'
      response.should_not have_tag('textarea#core_field_help_text')
    end

  end

end
