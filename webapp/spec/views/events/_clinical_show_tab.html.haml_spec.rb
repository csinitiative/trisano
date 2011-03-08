require 'spec_helper'

describe "/events/_clinical_show_tab.html.haml" do

  context "diagnostic facilities" do
    let(:event) { Factory.create(:morbidity_event) }

    before do
      mock_user
      assigns[:event] = event
      @facility = Factory.create(:diagnostic_facility)
      event.diagnostic_facilities << @facility
      render '/morbidity_events/show.html.erb'
    end

    it "should be rendered in a table" do
      doc = Nokogiri::HTML(response.body)
      result = doc.css('tr td').text.map(&:strip).join("\n")
      entity = @facility.place_entity
      [entity.place.name, entity.canonical_address.preferred_format, entity.place.formatted_place_descriptions].each do |value|
        result[value].should == value
      end
    end
  end

end
