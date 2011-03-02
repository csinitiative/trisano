Feature: Creating new place events

  Scenario: Creating a place event from an existing place
    Given I am logged in as a super user
    And a simple morbidity event for last name Frumpydoodle
    And a basic morbidity event exists
    And there is a place on the event named The Shack
    When I am on the place event edit page
    And I click the "Create new place exposure" link and wait to see "Place search"
    And I press "Search" and wait to see "Create a new place exposure"
    Then I should see "Create a new place exposure using this place"
    And I should not see "No results"

    When I follow "Create a new place exposure using this place"
    Then I should see "Successfully created place exposure."
    And I should see "Edit Place Event: The Shack"
    And I should see "School"

  Scenario: Searching for a non-existent place
    Given I am logged in as a super user
    And a simple morbidity event for last name Frumpydoodle
    And a basic morbidity event exists
    And there is a place on the event named The Shack
    When I am on the place event edit page
    And I click the "Create new place exposure" link and wait to see "Place search"
    And I fill in "place_search_name" with "Not The Shack"
    And I press "Search" and wait to see "Create a new place exposure"
    Then I should see "No results"
