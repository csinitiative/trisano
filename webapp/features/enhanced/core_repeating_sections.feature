Feature: Core form fields for repeating sections.

  To provide users with greater control over data collections
  I want to be able to add core form fields to repeating sections.

  Scenario: No core forms are applied, save multiple hospitalizations.
    Given I am logged in as a super user
    When I navigate to the new morbidity event page and start a simple event
    And I create the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
      | Alta View Hospital        |
      | American Fork Hospital    |
    And I save the event
    And I navigate to the morbidity event show page
    Then I should see the following in order:
      | Allen Memorial Hospital |
      | Alta View Hospital      |
      | American Fork Hospital  |
