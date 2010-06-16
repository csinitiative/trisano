require File.expand_path(File.dirname(__FILE__) +  '/../../../../../../spec/spec_helper')

include ApplicationHelper

describe "/events/_expected_delivery_form.html.haml" do

  describe "when the disease event is perinatal hep B" do

    it "displays a field for selecting the expected delivery hospital"

    it "displays a fields for entering the telephone of the expected delivery hospital"

  end

  describe "when the disease event is anything but perinatal hep B" do

    it "doesn't display a field for expected delivery hospital"

    it "doesn't diplay fields for entering the telephone of the expected delivery hospital"

  end

  describe "when there is no disease event" do
  end

end
