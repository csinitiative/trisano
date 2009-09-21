Feature: Place event, viewing core field help text

  To better enable a user to fill in an event form
  An investigator should see help text on core fields

  Scenario: Viewing place event help text
    Given I am logged in as a super user
    And all core field configs for a place event have help text
    And a morbidity event exists
    And there is a place on the event named Jimmy's Pool

    And I am on the place event edit page
    Then I should see help text for all place event core fields in edit mode

    When I fill in enough place event data to enable all core fields to show up in show mode
    And I save the event
    Then I should see help text for all place event core fields in show mode
