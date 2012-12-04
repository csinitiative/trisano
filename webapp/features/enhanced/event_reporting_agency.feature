Feature: Managing reporting agencies on events

  To enable users to add and remove reporting agencies
  I want to be able to add and remove reporting agencies

  Scenario: Adding and removing existing reporting agencies in new mode
    Given I am logged in as a super user
    And a place entity of type PUB exists
    When I navigate to the new morbidity event page and start a simple event
    And I add an existing reporting agency
    And I click remove for that reporting agency
    Then I should not see the reporting agency

    When I save and continue
    Then I should not see the reporting agency

  Scenario: Adding an existing reporting agency in new mode
    Given I am logged in as a super user
    And a place entity of type PUB exists
    When I navigate to the new morbidity event page and start a simple event
    And I add an existing reporting agency
    And I save and continue
    Then I should see the added reporting agency

  Scenario: Adding and removing existing reporting agencies in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a place entity of type PUB exists
    When I navigate to the morbidity event edit page
    And I add an existing reporting agency
    And I click remove for that reporting agency
    Then I should not see the reporting agency

  Scenario: Adding existing reporting agencies in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And a place entity of type PUB exists
    When I navigate to the morbidity event edit page
    And I add an existing reporting agency
    And I save and continue
    Then I should see the added reporting agency
