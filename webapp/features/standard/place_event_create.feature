Feature: Creating new place events

  Scenario: Creating a place event from place event edit
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a place on the event named "The Shack"
    When I navigate to the place event edit page
    And I follow "Create new place"
    Then I should see "New Place Exposure"

    When I fill in "Name" with "Swimmin' Place"
    And I check "place_event_interested_place_attributes__place_entity_attributes__place_attributes_place_type_P"
    And I fill in "Date of exposure" with "November 1, 2010"
    And I fill in "Street number" with "679"
    And I fill in "Street name" with "Friday Lane"
    And I fill in "City" with "Salt Lake City"
    And I select "Utah" from "place_event_address_attributes_state_id"
    And I fill in "New note" with "This is some place."
    And I save the new place event
    Then I should see "Successfully created place exposure."
    And I should have a note that says "This is some place."
    And I should have a note that says "Place event created."
    And I should see "Swimmin' Place"
    And I should see "Pool"
    And I should see "679"
    And I should see "Friday Lane"
    And I should see "Salt Lake City"
    And I should see "Utah"
    And the place should have the jurisdiction of its parent event
    And the place should have the disease of its parent event
    And the place should have a canonical address
    And the place name and place type should not be editable

  Scenario: Creating a place event from place event edit without a place name
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a place on the event named "The Shack"
    When I navigate to the place event edit page
    And I follow "Create new place"
    And I save the new place event
    Then I should see "No name has been supplied for this place."
    When I fill in "Name" with "Swimmin' Place"
    And I save the new place event
    Then I should see "Successfully created place exposure."

