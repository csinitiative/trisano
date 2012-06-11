require 'spec_helper'

describe SearchController do

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  context "the search form" do

    before :all do
      @user = Factory(:user)
      @role = Factory(:role)
      @user.role_memberships.create(:jurisdiction => create_jurisdiction_entity, :role => @role)
      @role.privileges << (Privilege.find_by_priv_name('view_event') || Factory(:privilege, :priv_name => 'view_event'))
      @diseases = [Factory(:disease, :sensitive => false), Factory(:disease, :sensitive => true)]
    end

    it "does not return sensitive diseases if the user doesn't have that privilege" do
      get "events", nil, {:user_id => @user.uid}
      assigns[:diseases].should == @diseases[0,1]
    end

    it "returns sensitive diseases if the user has that privilege" do
      @role.privileges << (Privilege.find_by_priv_name("access_sensitive_diseases") || Factory(:privilege, :priv_name => "access_sensitive_diseases"))
      get "events", nil, {:user_id => @user.uid}
      assigns[:diseases].should == @diseases
    end
  end
end
