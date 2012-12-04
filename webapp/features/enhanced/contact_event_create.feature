Feature: Creating new contact events

  Scenario: Creating a contact event from contact event edit
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a contact on the event named "The Shack"
    When I am on the contact event edit page
    And I click the "Create new contact event" link and wait to see "Contact search"
    Then I should see "Contact search"

    When I fill in "contact_search_name" with "A name that will return no search results"
    And I press "Search" and wait to see "Create a new contact"
    Then I should see "No results"
    And I should see "Create a new contact"

    When I follow "Create a new contact"
    And I fill in "Last name" with "Contacto"
    And I fill in "Street number" with "679"
    And I fill in "Street name" with "Friday Lane"
    And I fill in "City" with "Salt Lake City"
    And I select "Utah" from "State"
    And I fill in "New note" with "This is some contact."
    And I save and continue
    Then I should see "Contact event was successfully created."
    And I should have a note that says "This is some contact."
    And I should have a note that says "Contact event created."
    And I should see "Contacto"
    And I should see "679"
    And I should see "Friday Lane"
    And I should see "Salt Lake City"
    And I should see "Utah"
    And the contact should have the jurisdiction of its parent event
    And the contact should have the disease of its parent event
    And the contact should have a canonical address

  Scenario: Creating a contact event from contact event edit without a last name
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a contact on the event named "The Shack"
    When I am on the contact event edit page
    And I click the "Create new contact event" link and wait to see "Contact search"
    And I fill in "contact_search_name" with "A name that will return no search results"
    And I press "Search" and wait to see "Create a new contact"
    And I follow "Create a new contact"
    And I save and continue
    Then I should see "No information has been supplied for the interested party."

    When I fill in "Last name" with "Contacto"
    And I save and continue
    Then I should see "Contact event was successfully created."

  Scenario: Creating a contact event from an existing person
    Given I am logged in as a super user
    And a simple morbidity event for last name Frumpydoodle
    And a basic morbidity event exists
    And there is a contact on the event named "The Shack"
    When I am on the contact event edit page
    And I click the "Create new contact event" link and wait to see "Contact search"
    And I press "Search" and wait to see "Create a new contact"
    Then I should see "Create a new contact using this person"
    And I should not see "No results"

    When I follow "Create a new contact using this person"
    Then I should see "Contact event was successfully created."
    And I should see "Edit Contact event"
    And the contact should have the jurisdiction of its parent event
    And the contact should have the disease of its parent event

  Scenario: Trying an invalid search
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a contact on the event named "The Shack"
    When I am on the contact event edit page
    And I click the "Create new contact event" link and wait to see "Contact search"
    And I fill in "contact_search_name" with "Bad search!!!!"
    And I press "Search" and wait to see "Invalid search criteria"
    Then I should see "Invalid search criteria"
