require 'spec_helper'

describe "/events/_diagnostics_form.html.haml" do

  context "rendering a new facility" do
    let(:event) { Factory.build(:morbidity_event) }
    
    before do
      event.diagnostic_facilities << DiagnosticFacility.blank
      @event_form = ExtendedFormBuilder.new('morbidity_event', event, template, {}, nil)
      assigns[:event] = event
      render 'events/_diagnostics_form.html.haml', :locals => { :event_form => @event_form }
    end

    it "should render form fields" do
      response.should have_tag("input[id=?]", "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_place_attributes_name")
      Place.diagnostic_types.map(&:the_code).each do |code|
        response.should have_tag("input[id=?]", "morbidity_event_diagnostic_facilities_attributes__0__place_entity_attributes__place_attributes_place_type_#{code}")
      end
      %w(street_number street_name unit_number city state_id county_id postal_code).each do |address_part|
        response.should have_tag("[id=?]", "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_canonical_address_attributes_#{address_part}")
      end
    end

    it "should render a remove link" do
      response.should have_tag("a", "Remove")
    end
  end

  context "rendering an existing facility" do
    let(:event) { Factory.build(:morbidity_event) }

    before do
      @facility = Factory.create(:diagnostic_facility)
      event.diagnostic_facilities << @facility
      @event_form = ExtendedFormBuilder.new('morbidity_event', event, template, {}, nil)
      render 'events/_diagnostics_form.html.haml', :locals => { :event_form => @event_form }
    end

    it "should render fields as text" do
      doc = Nokogiri::HTML(response.body)
      spans = doc.css('span').text
      spans.should =~ /#{@facility.place_entity.place.name}/
      spans.should =~ /#{@facility.place_entity.place.formatted_place_descriptions}/
      %w(street_number street_name unit_number city postal_code).each do |address_part|
        spans.should =~ /#{@facility.place_entity.canonical_address.send(address_part)}/
      end
      %w(state county).each do |field|
        spans.should =~ /#{@facility.place_entity.canonical_address.send(field).code_description}/
      end
    end

    it "should not render form fields" do
      response.should_not have_tag("input[id=?]", "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_place_attributes_name")
      Place.diagnostic_types.map(&:the_code).each do |code|
        response.should_not have_tag("input[id=?]", "morbidity_event_diagnostic_facilities_attributes__0__place_entity_attributes__place_attributes_place_type_#{code}")
      end
      %w(street_number street_name unit_number city state_id county_id postal_code).each do |address_part|
        response.should_not have_tag("[id=?]", "morbidity_event_diagnostic_facilities_attributes_0_place_entity_attributes_canonical_address_attributes_#{address_part}")
      end
    end

    it "should render a remove check box" do
      response.should have_tag("input[type='checkbox'][id=?]", "morbidity_event_diagnostic_facilities_attributes_0__destroy")
    end
  end
end
