Feature: Morbidity event, viewing core field help text

  To better enable a user to fill in an event form
  An investigator should see help text on core fields

  Scenario: Viewing morbidity event help text
    Given I am logged in as a super user
    And all core field configs for a morbidity event have help text
    And a basic morbidity event exists

    When I am on the event edit page
    Then I should see help text for all morbidity event core fields in edit mode

    When I fill in enough morbidity event data to enable all core fields to show up in show mode
    And I save the event
    Then I should see help text for all morbidity event core fields in show mode
