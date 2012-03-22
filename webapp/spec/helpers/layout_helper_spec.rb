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
