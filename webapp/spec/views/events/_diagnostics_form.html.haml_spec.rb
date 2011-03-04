require 'spec_helper'

describe "/events/_diagnostics_form.html.haml" do
  context "rendering a new facility" do
    let(:event) { Factory.build(:morbidity_event) }

    it "should render form fields" do
      assigns[:event] = event
      render 'events/_diagnostics_form.html.haml'
      response.should have_tag("input[id=?]", "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_place_attributes_name")
    end
  end
end
