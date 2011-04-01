require 'spec_helper'

describe "Finding translated gender" do

  before :all do
    ParticipationsRiskFactor.delete_all
    HospitalsParticipation.delete_all
    Participation.delete_all
    DiseaseEvent.delete_all
    Event.delete_all
    Person.delete_all
    PersonEntity.delete_all
  end

  after :all do
    Fixtures.reset_cache
  end

  before do
    User.current_user = Factory.create(:user)

    @gender = ExternalCode.find(:first, :conditions => {:the_code => 'M', :code_name => 'gender'})
    @gender.code_translations.build(:locale => 'test', :code_description => 'xMale').save!
    @event = returning Factory.build(:morbidity_event) do |event|
      event.update_attributes!({
          :interested_party_attributes => {
            :person_entity_attributes => {
              :person_attributes => {
                :last_name    => 'James',
                :birth_gender => @gender}}}})
    end
  end

  after do
    I18n.locale = :en
  end

  it "should return the default locale's translation" do
    results = HumanEvent.find_by_name_and_bdate(:last_name => 'James')
    results[0]['birth_gender'].should == 'Male'
  end

  it "should return the :test locale's translation" do
    I18n.locale = :test
    results = HumanEvent.find_by_name_and_bdate(:last_name => 'James')
    results[0]['birth_gender'].should == 'xMale'
  end

end
