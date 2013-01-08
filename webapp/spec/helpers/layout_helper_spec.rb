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
require RAILS_ROOT + '/app/helpers/application_helper'
include ApplicationHelper

describe LayoutHelper do
  
  context "rendering the footer" do
    include Trisano

    it "includes a link to the release notes" do
      helper.expects(:link_to_release_notes).with(application.actual_name).returns("")
      helper.render_footer
    end
  end

  context "release notes link" do
    it "uses the release notes url" do
      helper.expects(:release_notes_url).returns("http://bogus_notes.com")
      helper.link_to_release_notes('Actual Name 1.0').should have_tag("a[href='http://bogus_notes.com']")
    end
  end

  context "release notes url" do
    include Trisano

    it "is composed of a subscription space and the version of the code base" do
      application.expects(:subscription_space).returns('tri')
      helper.release_notes_url.should =="https://wiki.csinitiative.com/display/tri/TriSano+-+#{application.version_number}+Release+Notes"
    end
  end
      
end
