Feature: Printer friendly morbidity events

  To better be able to review cases
  An ivestigator
  Needs to be able to print cmrs out in a readable format

  Scenario: Printing a morbidity event should print any associated Contact events
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |
      |Abbot    |Bud       |

    When I print the morbidity event

    Then I should see "Miles" under contact reports
    And I should see "Davis" under contact reports
    And I should see "Bud" under contact reports
    And I should see "Abbot" under contact reports

  Scenario: Printing a morbidity event should not print deleted Contact events
    Given I am logged in as a super user
    And a morbidity event exists with the disease Mumps
    And the morbidity event has the following contacts:
      |last_name|first_name|
      |Davis    |Miles     |
    And the morbidity event has the following deleted contacts:
      |last_name|first_name|
      |Abbot    |Bud       |
  
    When I print the morbidity event

    Then I should see "Miles" under contact reports
    And I should see "Davis" under contact reports
    And I should not see "Bud" under contact reports
    And I should not see "Abbot" under contact reports

      
