require 'spec_helper'

describe "/events/_clinical_show_print.html.haml" do

  context "printing disagnostic facilities" do
    let(:event) { Factory.create(:morbidity_event) }

    before do
      mock_user
      assigns[:event] = event
      assigns[:print_options] = [I18n.t('clinical')]
      @facility = Factory.create(:diagnostic_facility)
      event.diagnostic_facilities << @facility
      render "/morbidity_events/show.print.haml"
      @printed_values = Nokogiri::HTML(response.body).css(".print-value").text.map(&:strip).join("\n")
    end

    it "should show place name" do
      @printed_values[@facility.place_entity.place.name].should == @facility.place_entity.place.name
    end

    it "should show place address" do
      address = @facility.place_entity.canonical_address.preferred_format
      @printed_values[address].should == address
    end

    it "should show place type" do
      type = @facility.place_entity.place.formatted_place_descriptions
      @printed_values[type].should == type
    end
  end
end
