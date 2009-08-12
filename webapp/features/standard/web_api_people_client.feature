Feature: Web API People Client

  To create and modify people entity records programmatically
  An interface is needed that can be integrated into code

  Scenario: Viewing existing person entity
    Given I have a known person entity
    
    When I visit the person show page

    Then I should find the value "Robert" in "data_first_name"
    And I should find the value "Michael" in "data_middle_name"
    And I should find the value "Smith-Johnson" in "data_last_name"
    And I should find the value "1980-11-10" in "data_birth_date"
    And I should find the value "Male" in "data_birth_gender"
    And I should find the value "English" in "data_primary_language"
    And I should find the value "Hispanic or Latino" in "data_ethnicity"
    And I should find the value "White" in "data_race"
    And I should find the value "123" in "data_street_number"
    And I should find the value "George Mason Dr." in "data_street_name"
    And I should find the value "448" in "data_unit_number"
    And I should find the value "Utah" in "data_state"
    And I should find the value "Beaver" in "data_county"
    And I should find the value "foo@bar.com" in "data_email_address"
    And I should find the value "(555) 555-5555" in "data_telephone"

  Scenario: Listing people entities
    Given I have a known person entity

    When I visit the people index page

    Then I should find the value "Robert" in "data_first_name"
    And I should find the value "Michael" in "data_middle_name"
    And I should find the value "Smith-Johnson" in "data_last_name"
    And I should find the value "123" in "data_street_number"
    And I should find the value "George Mason Dr." in "data_street_name"
    And I should find the value "448" in "data_unit_number"
    And I should find the value "Utah" in "data_state"
    And I should find the value "Beaver" in "data_county"

  Scenario: Searching known people entities
    Given I have a known person entity

    When I search people by "last_name" with "Smith-Johnson"

    Then I should find the value "Robert" in "data_first_name"
    And I should find the value "Michael" in "data_middle_name"
    And I should find the value "Smith-Johnson" in "data_last_name"
    And I should find the value "123" in "data_street_number"
    And I should find the value "George Mason Dr." in "data_street_name"
    And I should find the value "448" in "data_unit_number"
    And I should find the value "Utah" in "data_state"
    And I should find the value "Beaver" in "data_county"

  Scenario: Searching people entities with no results
    Given I have a known person entity

    When I search people by "last_name" with "Richardson"

    Then I should not find the value "Smith-Johnson" in "data_last_name"

  Scenario: Create person entity
    When I visit the people new page
    And I fill out the form field "person_entity[person_attributes][last_name]" with "Bourne-Thompson"
    And I press "Create"
    And I search people by "last_name" with "Bourne-Thompson"

    Then I should find the value "Bourne-Thompson" in "data_last_name"

  Scenario: Edit person entity
    Given I have a known person entity

    When I visit the people edit page
    And I fill out the form field "person_entity[person_attributes][last_name]" with "Bourne-Thompson"
    And I press "Update"
    And I search people by "last_name" with "Bourne-Thompson"

    Then I should find the value "Bourne-Thompson" in "data_last_name"
