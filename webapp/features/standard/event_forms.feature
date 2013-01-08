Feature: Managing forms on events

  Scenario: Update event forms should pop up after disease update if new forms are present
    Given I am logged in as a super user
    And the following diseases:
        | disease_name  |
        | Anthrax       |
        | AIDS          |
    And a morbidity event live form for Anthrax in unassigned jurisdiction exists
    And a morbidity event live form for AIDS in unassigned jurisdiction exists
    And a basic morbidity event in unassigned jurisdiction with disease Anthrax exists
    When I navigate to the morbidity event edit page
    And I select "AIDS" from "Disease"
    And I save the event
    Then I should see event forms popup

  Scenario: Update event forms should pop up after disease update if old forms are present
    Given I am logged in as a super user
    And the following diseases:
        | disease_name  |
        | Anthrax       |
        | AIDS          |
    And a morbidity event live form for AIDS in unassigned jurisdiction exists
    And a basic morbidity event in unassigned jurisdiction with disease AIDS exists
    When I navigate to the morbidity event edit page
    And I select "Anthrax" from "Disease"
    And I save the event
    Then I should see event forms popup

  Scenario: Should not see event forms popup if no disease update
    Given I am logged in as a super user
    And a morbidity event live form for AIDS in unassigned jurisdiction exists
    And a basic morbidity event in unassigned jurisdiction with disease AIDS exists
    When I navigate to the morbidity event edit page
    And I save the event
    Then I should not see event forms popup

  Scenario: Should not see event forms popup if no form changes present
    Given I am logged in as a super user
    And the following diseases:
        | disease_name  |
        | Anthrax       |
    And a basic morbidity event in unassigned jurisdiction with disease Asthma exists
    When I navigate to the morbidity event edit page
    And I select "Anthrax" from "Disease"
    And I save the event
    Then I should not see event forms popup