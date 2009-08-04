Feature: Managing reporting agencies on events

  To enable users to add and remove reporting agencies
  I want to be able to add and remove reporting agencies

  Scenario: Adding and removing existing reporting agencies in new mode
    Given I am logged in as a super user
    And a place entity of type Public exists

    When I navigate to the new event page and start a simple event
    And I add an existing reporting agency
    And I click remove for that reporting agency
    Then I should not see the reporting agency

    When I add an existing reporting agency
    And I save the event
    Then I should see the added reporting agency

  Scenario: Adding and removing existing reporting agencies in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a place entity of type Public exists

    When I navigate to the event edit page
    And I add an existing reporting agency
    And I click remove for that reporting agency
    Then I should not see the reporting agency

   When I add an existing reporting agency
    And I save the event
    Then I should see the added reporting agency
