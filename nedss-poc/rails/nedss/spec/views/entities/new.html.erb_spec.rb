require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/new.html.erb" do
  include EntitiesHelper
  include PersonFormSpecHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')

  def do_render
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
    render "/entities/new.html.erb"
  end

  it_should_behave_like "a person form"

  before(:each) do
    @entity.stub!(:new_record?).and_return(true)
  end

  it "should render new person form" do
    do_render
    response.should have_tag("form[action=?][method=post]", entities_path) do
    end
  end
  
  it "should link back to various indexes" do
    do_render
    response.should have_tag("a[href=/entities?type=person]")
    response.should have_tag("a[href=/entities?type=animal]")
    response.should have_tag("a[href=/entities?type=material]")
    response.should have_tag("a[href=/entities?type=place]")
  end

  it "New form should include location fields" do
    do_render

    response.should have_tag("form") do
      with_tag("input#entity_person_last_name[name=?]", "entity[person][last_name]")

      with_tag('select#entity_entities_location_entity_location_type_id[name=?]', "entity[entities_location][entity_location_type_id]") do
        with_tag('option', 'Home')
        with_tag('option', 'Work')
      end

      with_tag('select#entity_entities_location_primary_yn_id[name=?]', "entity[entities_location][primary_yn_id]") do
        with_tag('option', 'Unknown')
        with_tag('option', 'Yes')
        with_tag('option', 'No')
      end

      with_tag("input#entity_address_street_number[name=?]", "entity[address][street_number]")
      with_tag("input#entity_address_street_name[name=?]", "entity[address][street_name]")
      with_tag("input#entity_address_unit_number[name=?]", "entity[address][unit_number]")
      with_tag("input#entity_address_street_number[name=?]", "entity[address][street_number]")
    end
  end

end


