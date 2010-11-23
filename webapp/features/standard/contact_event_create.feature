Feature: Creating new contact events

  Scenario: Creating a contact event from contact event edit
    Given I am logged in as a super user
    And a basic morbidity event exists
    And there is a contact on the event named "The Shack"
    When I navigate to the contact event edit page
    And I follow "Create new contact"
    Then I should see "New contact event"

    When I fill in "Last name" with "Contacto"
    And I fill in "Street number" with "679"
    And I fill in "Street name" with "Friday Lane"
    And I fill in "City" with "Salt Lake City"
    And I select "Utah" from "contact_event_address_attributes_state_id"
    And I fill in "New note" with "This is some contact."
    And I save the new contact event
    Then I should see "Successfully created contact event."
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
    When I navigate to the contact event edit page
    And I follow "Create new contact event"
    And I save the new contact event
    Then I should see "No information has been supplied for the interested party."
    When I fill in "Last name" with "Contacto"
    And I save the new contact event
    Then I should see "Successfully created contact event."
