Feature: Managing clinicians on events

  To enable users to add and remove clinicians
  I want to be able to add and remove clinicians

  Scenario: Adding and removing clinicians in new morbidity mode
    Given I am logged in as a super user
    And there is a clinician

    When I navigate to the new morbidity event page and start a simple event
    And I add an existing clinician
    And I click remove for that clinician
    Then I should not see the clinician

    When I add an existing clinician
    And I add a new clinician
    And I save and continue
    Then I should see all added clinicians

    When I navigate to the morbidity event edit page
    And I check a clinician to remove
    And I save and continue
    Then I should not see the removed clinician

  Scenario: Adding clinicians in edit morbidity mode
    Given I am logged in as a super user
    And there is a clinician
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the morbidity event edit page
    And I add an existing clinician
    And I add a new clinician
    And I save and continue
    Then I should see all added clinicians

  Scenario: Clinician search should not include deleted clinicians in morbidity events
    Given I am logged in as a super user
    And a deleted clinician exists with a name similar to another clinician
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the morbidity event edit page
    Then I should not see the deleted clinician


  Scenario: Adding and removing clinicians in new assessment mode
    Given I am logged in as a super user
    And there is a clinician

    When I navigate to the new assessment event page and start a simple event
    And I add an existing clinician
    And I click remove for that clinician
    Then I should not see the clinician

    When I add an existing clinician
    And I add a new clinician
    And I save and continue
    Then I should see all added clinicians

    When I navigate to the assessment event edit page
    And I check a clinician to remove
    And I save and continue
    Then I should not see the removed clinician

  Scenario: Adding clinicians in edit assessment mode
    Given I am logged in as a super user
    And there is a clinician
    And a assessment event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the assessment event edit page
    And I add an existing clinician
    And I add a new clinician
    And I save and continue
    Then I should see all added clinicians

  Scenario: Clinician search should not include deleted clinicians in assessment
    Given I am logged in as a super user
    And a deleted clinician exists with a name similar to another clinician
    And a assessment event exists in Bear River with the disease African Tick Bite Fever

    When I navigate to the assessment event edit page
    Then I should not see the deleted clinician

