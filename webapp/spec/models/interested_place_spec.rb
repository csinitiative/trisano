require File.dirname(__FILE__) + '/../spec_helper'

describe InterestedPlace do
  it 'should not be valid if associated place doesn\'t have a name' do
    InterestedPlace.create.errors.on_base.should == 'No name has been supplied for this place.'
  end
end
