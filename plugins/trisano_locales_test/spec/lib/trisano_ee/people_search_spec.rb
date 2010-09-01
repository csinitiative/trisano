require 'spec_helper'

describe Person, "searching w/ translated fields" do

  before do
    @joins = Person.people_search_joins({})
  end

  it "should join to translation table for state names" do
    @joins.should == ["INNER JOIN entities on people.entity_id = entities.id",
                      "LEFT JOIN addresses ON people.entity_id = addresses.entity_id AND addresses.event_id IS NULL",
                      "LEFT JOIN external_code_translations AS states ON addresses.state_id = states.external_code_id AND states.locale = 'en'"]
  end

end
