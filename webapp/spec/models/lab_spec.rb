require 'spec_helper'

describe Lab do
  it "should not allow a lab (participation) to be built w/ a deleted place entity" do
    event = Factory(:morbidity_event)
    deleted_place_entity = Factory(:place_entity, :deleted_at => DateTime.now)
    participation = Lab.new(:event => event,
                            :primary_entity => event.interested_party.person_entity,
                            :secondary_entity => deleted_place_entity)
    participation.should_not be_valid
    participation.errors.size.should == 1
    participation.errors.full_messages.first.should =~ /#{deleted_place_entity.place.name.humanize} has been merged/i
  end

end
