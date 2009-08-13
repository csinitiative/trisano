Feature: Managing contacts on events

  To enable users to add and remove contacts
  I want to be able to add and remove contacts

  Scenario: Adding and removing contacts in new mode
    Given I am logged in as a super user
    And a contact event exists

    When I navigate to the new event page and start a simple event
    And I add an existing contact
    And I click remove for that contact
    Then I should not see the contact

    When I add an existing contact
    And I add a new contact
    And I save the event
    Then I should see all added contacts

    When I navigate to the event edit page
    And I check a contact to remove
    And I save the event
    Then the removed contact should be struckthrough

  Scenario: Adding contacts in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a contact event exists

    When I navigate to the event edit page
    And I add an existing contact
    And I click remove for that contact
    Then I should not see the contact

    When I add an existing contact
    And I add a new contact
    And I save the event
    Then I should see all added contacts
