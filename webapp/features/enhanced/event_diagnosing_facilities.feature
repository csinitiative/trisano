Feature: Managing diagnosing facilities on events

  To enable users to add and remove diagnosing facilities
  I want to be able to add and remove diagnosing facilities

  Scenario: Adding and removing diagnosing facilities in new mode
    Given I am logged in as a super user

    When I navigate to the new morbidity event page and start a simple event
    And I add an existing diagnosing facility
    And I click remove for that diagnosing facility
    Then I should not see the diagnosing facility

    When I add an existing diagnosing facility
    And I add a new diagnosing facility
    And I save and continue
    Then I should see all added diagnosing facilities

    When I navigate to the morbidity event edit page
    And I remove all of the diagnostic facilities
    Then I should not see the removed diagnostic facility

  Scenario: Adding diagnosing facilities in edit mode
    Given I am logged in as a super user
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the morbidity event edit page
    And I add an existing diagnosing facility
    And I click remove for that diagnosing facility
    Then I should not see the diagnosing facility

    When I add an existing diagnosing facility
    And I add a new diagnosing facility
    And I save and continue
    Then I should see all added diagnosing facilities
    
  Scenario: Adding and removing diagnosing facilities for a contact
    Given I am logged in as a super user
    And there is a contact event
    When I am on the contact event edit page
    And I add an existing diagnosing facility
    And I click remove for that diagnosing facility
    Then I should not see the diagnosing facility
    When I add an existing diagnosing facility
    And I add a new diagnosing facility
    And I save and continue
    Then I should see all added diagnosing facilities
    When I am on the contact event edit page
    And I remove all of the diagnostic facilities
    Then I should not see the removed diagnostic facility

