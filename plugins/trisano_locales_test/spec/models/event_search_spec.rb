require 'spec_helper'

describe "Finding translated codes" do

  before :all do
    ParticipationsRiskFactor.delete_all
    DiseaseEvent.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM diseases_export_columns;")
    Disease.delete_all
    HospitalsParticipation.delete_all
    Participation.delete_all
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

    @county = ExternalCode.find(:first, :conditions => {:the_code => "SL", :code_name => 'county'})
    @county.code_translations.build(:locale => 'test', :code_description => 'xSalt Lake').save!

    @event = returning Factory.build(:morbidity_event) do |event|
      event.update_attributes!({
          :address_attributes => {
            :county => @county },
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


  describe "name and birth date search" do
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

  describe "find by criteria" do
    it "should return the default locale's translation" do
      results = Event.find_by_criteria(:fulltext_terms => 'James')
      results[0]['birth_gender'].should == 'Male'
      results[0]['county'].should == 'Salt Lake'
    end

    it "should return the :test locale's translation" do
      I18n.locale = :test
      results = Event.find_by_criteria(:fulltext_terms => 'James')
      results[0]['birth_gender'].should == 'xMale'
      results[0]['county'].should == 'xSalt Lake'
    end
  end

end
