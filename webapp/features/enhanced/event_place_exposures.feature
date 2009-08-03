Feature: Managing place exposures on events

  To enable users to add and remove place exposures
  I want to be able to add and remove place exposures

  Scenario: Adding and removing place exposures in new mode
    Given I am logged in as a super user
    And a place entity of type Food Establishment exists

    When I navigate to the new event page and start a simple event
    And I add an existing place exposure
    And I click remove for that place exposure
    Then I should not see the place exposure

    When I add an existing place exposure
    And I add a new place exposure
    And I save the event
    Then I should see all added place exposures

    When I navigate to the event edit page
    And I check a place exposure to remove
    And I save the event
    Then I should see the removed place exposure as deleted

  Scenario: Adding and removing place exposures in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a place entity of type Food Establishment exists

    When I navigate to the event edit page
    And I add an existing place exposure
    And I click remove for that place exposure
    Then I should not see the place exposure

   When I add an existing place exposure
    And I add a new place exposure
    And I save the event
    Then I should see all added place exposures

  Scenario: Adding two new place exposures at once
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    When I navigate to the event edit page
    And I add two new place exposures
    And I save the event
    Then I should see both new place exposures

Scenario: Editing a place exposure as a place event
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the event edit page
    And I add a new place exposure
    And I save the event

    When I navigate to the place event
    And I edit the place event
    And I save the place event
    Then I should see the edited place event

