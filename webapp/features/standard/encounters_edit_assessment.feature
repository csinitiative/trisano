Feature: Editing encounters

  Background:
    Given a user with uid "joe"
    And a user with uid "alice"
    And "joe" is an investigator in "Bear River"
    And "alice" is an investigator in "Weber-Morgan"
    And a assessment event exists in jurisdiction "Weber-Morgan"
    And the event has an encounter
    And the encounter investigator is "joe"

  Scenario: Updating an event w/ encounters just forwarded from another jurisdiction
    Given I am logged in as "alice"
    When I go to the assessment event edit page
    And I save the event
    Then I should see "joe" in the encounters table
    And I should not see "alice" in the encounters table
