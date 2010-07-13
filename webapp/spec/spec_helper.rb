# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

require 'spec/autorun'
require 'spec/rails'
require 'spec/custom_matchers'
require 'nokogiri'
require 'validates_timeliness/matcher'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |f|
  require File.expand_path(f)
end

# Load up factories
#Dir[File.join(File.dirname(__FILE__), '..', '{vendor/trisano/*/spec}', 'factories', '*.rb')].each do |f|
#  require File.expand_path(f)
#end

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(CustomMatchers)

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  config.global_fixtures = :codes, :external_codes
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner

  config.after(:each) {
     User.current_user = nil
  }
end

# Bypass nested set logic to invalidate the provided form.
def invalidate_form(form)
  ActiveRecord::Base.connection.execute("update form_elements set parent_id = null where id = #{form.investigator_view_elements_container.id}")
end

# Bypass nested set logic to invalidate the provided tree's root
def invalidate_tree(tree_root)
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 1 where id = #{tree_root.id}")
end

def mock_user
  @jurisdiction = Factory.build(:place_entity)
  @place = Factory.build(:place)

  @user = Factory.build(:user)
  User.stubs(:find_by_uid).returns(@user)
  User.stubs(:current_user).returns(@user)
  @user.stubs(:id).returns(1)
  @user.stubs(:uid).returns("utah")
  @user.stubs(:user_name).returns("default_user")
  @user.stubs(:first_name).returns("Johnny")
  @user.stubs(:last_name).returns("Johnson")
  @user.stubs(:given_name).returns("Johnny")
  @user.stubs(:initials).returns("JJ")
  @user.stubs(:generational_qualifer).returns("")
  @user.stubs(:is_admin?).returns(true)
  @user.stubs(:jurisdictions_for_privilege).returns([@place])
  @user.stubs(:is_entitled_to?).returns(true)
  @user.stubs(:event_view_settings).returns(nil)
  @user.stubs(:best_name).returns("Johnny Johnson")
  @user.stubs(:disabled?).returns(false)
  @user.stubs(:destroyed?).returns(false)

  @role_membership = Factory.build(:role_membership)
  @role = Factory.build(:role)

  @role.stubs(:role_name).returns("administrator")
  @role_membership.stubs(:role).returns(@role)
  @role_membership.stubs(:jurisdiction).returns(@jurisdiction)
  @role_membership.stubs(:role_id).returns("1")
  @role_membership.stubs(:jurisdiction_id).returns("75")
  @role_membership.stubs(:should_destroy).returns(0)
  @role_membership.stubs(:is_admin?).returns(true)
  @role_membership.stubs(:id=).returns(1)
  @jurisdiction.stubs(:places).returns([@place])
  @jurisdiction.stubs(:place).returns(@place)
  @place.stubs(:name).returns("Southeastern District")
  @place.stubs(:entity_id).returns("1")

  @user.stubs(:role_memberships).returns([@role_membership])
  @user.stubs(:admin_jurisdiction_ids).returns([75])
  @user.stubs(:is_entitled_to_in?).returns(true)
  @user.stubs(:new_record?).returns(false)

  @user
end

def mock_event
  event = Factory.build(:morbidity_event)
  person = mock_person_entity

  imported_from = Factory.build(:external_code)
  state_case_status = Factory.build(:external_code)
  lhd_case_status = Factory.build(:external_code)
  outbreak_associated = Factory.build(:code)
  hospitalized = Factory.build(:external_code)
  died = Factory.build(:external_code)
  pregnant = Factory.build(:external_code)
  specimen_source = Factory.build(:external_code)
  specimen_sent_to_state = Factory.build(:external_code)

  disease_event = Factory.build(:disease_event)
  disease = Factory.build(:disease)
  lab_result = Factory.build(:lab_result)
  answer = Factory.build(:answer)

  jurisdiction = Factory.build(:jurisdiction)
  interested_party = Factory.build(:interested_party)
  lab = Factory.build(:lab)
  diagnostic = Factory.build(:diagnostic_facility)
  hospital = Factory.build(:hospitalization_facility)

  disease.stubs(:disease_id).returns(1)
  disease.stubs(:disease_name).returns("Bubonic,Plague")
  disease.stubs(:treatment_lead_in).returns("")
  disease.stubs(:place_lead_in).returns("")
  disease.stubs(:contact_lead_in).returns("")

  imported_from.stubs(:code_description).returns('Utah')
  state_case_status.stubs(:code_description).returns('Confirmed')
  lhd_case_status.stubs(:code_description).returns('Confirmed')
  outbreak_associated.stubs(:code_description).returns('Yes')
  hospitalized.stubs(:code_description).returns('Yes')
  died.stubs(:code_description).returns('No')
  pregnant.stubs(:code_description).returns('No')

  jurisdiction.stubs(:secondary_entity_id).returns(75)

  interested_party.stubs(:primary_entity).returns(1)
  interested_party.stubs(:person_entity).returns(person)

  disease_event.stubs(:disease_id).returns(1)
  disease_event.stubs(:hospital_id).returns(13)
  disease_event.stubs(:hospitalized).returns(hospitalized)
  disease_event.stubs(:hospitalized_id).returns(1401)
  disease_event.stubs(:died_id).returns(1401)
  disease_event.stubs(:died).returns(died)
  disease_event.stubs(:pregnant).returns(pregnant)
  disease_event.stubs(:disease).returns(disease)
  disease_event.stubs(:date_diagnosed).returns("2008-02-15")
  disease_event.stubs(:disease_onset_date).returns("2008-02-13")
  disease_event.stubs(:pregnant_id).returns(1401)
  disease_event.stubs(:pregnancy_due_date).returns("")

  specimen_source.stubs(:code_description).returns('Tissue')
  specimen_sent_to_state.stubs(:code_description).returns('Yes')

  lab_result.stubs(:specimen_source_id).returns(1501)
  lab_result.stubs(:specimen_source).returns(specimen_source)
  lab_result.stubs(:collection_date).returns("2008-02-14")
  lab_result.stubs(:lab_test_date).returns("2008-02-15")

  lab_result.stubs(:specimen_sent_to_state_id).returns(1401)
  lab_result.stubs(:specimen_sent_to_state).returns(specimen_sent_to_state)

  event.stubs(:all_jurisdictions).returns([jurisdiction])
  event.stubs(:labs).returns([lab])
  event.stubs(:diagnosing_health_facilities).returns([diagnostic])
  event.stubs(:hospitalized_health_facilities).returns([hospital])
  event.stubs(:jurisdiction).returns(jurisdiction)
  event.stubs(:interested_party).returns(interested_party)
  event.stubs(:record_number).returns("2008537081")
  event.stubs(:event_name).returns('Test')
  event.stubs(:event_onset_date).returns("2008-02-19")
  event.stubs(:disease_event).returns(disease_event)
  event.stubs(:lab_result).returns(lab_result)
  event.stubs(:event_status).returns("NEW")
  event.stubs(:imported_from_id).returns("2101")
  event.stubs(:imported_from).returns(imported_from)
  event.stubs(:state_case_status_id).returns(1801)
  event.stubs(:lhd_case_status_id).returns(1801)
  event.stubs(:state_case_status).returns(state_case_status)
  event.stubs(:lhd_case_status).returns(lhd_case_status)
  event.stubs(:outbreak_associated_id).returns(1401)
  event.stubs(:outbreak_associated).returns(outbreak_associated)
  event.stubs(:outbreak_name).returns("Test Outbreak")
  event.stubs(:investigation_started_date).returns("2008-02-05")
  event.stubs(:investigation_completed_LHD_date).returns("2008-02-08")
  event.stubs(:review_completed_by_state_date).returns("2008-02-11")
  event.stubs(:first_reported_PH_date).returns("2008-02-07")
  event.stubs(:results_reported_to_clinician_date).returns("2008-02-08")
  event.stubs(:MMWR_year).returns("2008")
  event.stubs(:MMWR_week).returns("7")
  event.stubs(:answers).returns([answer])
  event.stubs(:form_references).returns([])
  event.stubs(:under_investigation?).returns(true)
  event.stubs(:interested_party=)
  event.stubs(:get_investigation_forms).returns(nil)
  event.stubs(:safe_call_chain).with(:disease_event, :disease, :disease_name).returns("Bubonic,Plague")
  event.stubs(:deleted_at).returns(nil)
  event.stubs(:updated_at).returns(Time.new)
  event
end

def mock_person_entity
  person = Factory.build(:person)
  person.stubs(:entity_id).returns("1")
  person.stubs(:last_name).returns("Marx")
  person.stubs(:first_name).returns("Groucho")
  person.stubs(:middle_name).returns("Julius")
  person.stubs(:birth_date).returns(Date.parse('1902-10-2'))
  person.stubs(:date_of_death).returns(Date.parse('1970-4-21'))
  person.stubs(:birth_gender_id).returns(1)
  person.stubs(:birth_gender).returns(nil)
  person.stubs(:ethnicity_id).returns(101)
  person.stubs(:primary_language_id).returns(301)
  person.stubs(:approximate_age_no_birthday).returns(50)
  person.stubs(:food_handler_id).returns(1401)
  person.stubs(:healthcare_worker_id).returns(1401)
  person.stubs(:group_living_id).returns(1401)
  person.stubs(:day_care_association_id).returns(1401)
  person.stubs(:risk_factors).returns("None")
  person.stubs(:risk_factors_notes).returns("None")

  address = Factory.build(:address)
  address.stubs(:street_number).returns("123")
  address.stubs(:street_name).returns("Elm St.")
  address.stubs(:unit_number).returns("99")
  address.stubs(:city).returns("Provo")
  address.stubs(:state_id).returns(1001)
  address.stubs(:postal_code).returns("12345")
  address.stubs(:county_id).returns(1101)

  phone = Factory.build(:telephone)
  phone.stubs(:area_code).returns("212")
  phone.stubs(:phone_number).returns("5551212")
  phone.stubs(:extension).returns("4444")

  entity = Factory.build(:person_entity)
  entity.stubs(:entity_type).returns('PersonEntity')
  entity.stubs(:person).returns(person)
  entity.stubs(:address).returns(address)
  entity.stubs(:telephone).returns(phone)
  entity.stubs(:race_ids).returns([201])
  entity
end

require File.join(File.dirname(__FILE__), 'rails_ext') unless ActiveRecord::Base.respond_to? :_find_by_sql_with_capture

# now look for trisano plugin spec helpers
Dir[File.join(RAILS_ROOT, 'vendor', 'trisano', '*', 'spec', 'spec_helpers', '*.rb')].each do |f|
  require f
end
