Feature: Morbidity event, viewing core field help text

  To better enable a user to fill in an event form
  An investigator should see help text on core fields

  @flush_core_fields_cache
  Scenario: Viewing morbidity event help text
    Given I am logged in as a super user
    And all core field configs for a morbidity event have help text
    And a basic morbidity event exists
    And a lab named "Labby"

    When I am on the morbidity event edit page
    Then I should see help text for all morbidity event core fields in edit mode

    When I fill in enough morbidity event data to enable all core fields to show up in show mode
    And I save and continue
    Then I should see help text for all morbidity event core fields in show mode
