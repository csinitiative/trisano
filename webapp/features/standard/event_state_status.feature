Feature: State status only editable by state managers

  Scenario: State manager editing state status
    Given I am logged in as a state manager
      And a simple morbidity event in jurisdiction Bear River for last name Johnson
    When I navigate to the morbidity event edit page
    Then the state status should be editable
    
  Scenario: LHD manager viewing state status
    Given I am logged in as a lhd manager
      And a simple morbidity event in jurisdiction Bear River for last name Johnson
    When I navigate to the morbidity event edit page
    Then the state status should not be editable

  Scenario: Investigator viewing state status
    Given I am logged in as an investigator
      And a simple morbidity event in jurisdiction Bear River for last name Johnson
    When I navigate to the morbidity event edit page
    Then the state status should not be editable

  Scenario: Data-entry tech viewing state status
    Given I am logged in as a data entry tech
      And a simple morbidity event in jurisdiction Bear River for last name Johnson
    When I navigate to the morbidity event edit page
    Then the state status should not be editable
