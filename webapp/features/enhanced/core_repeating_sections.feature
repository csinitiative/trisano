Feature: Core form fields for repeating sections.

  To provide users with greater control over data collections
  I want to be able to add core form fields to repeating sections.

  Scenario: Creating CMR with no core forms are applied, save multiple hospitalizations.
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
    And I navigate to the morbidity event edit page
    Then I should see "Add a Hospitalization Facility"


  Scenario: Creating a CMR with repeater core forms applied, save multiple hospitalizations.
    Given I am logged in as a super user
    And a published form with repeating core fields for a morbidity event
    When I navigate to the new morbidity event page and start a event with the form's disease
    And I create the following hospitalizations: 
      | name                      |
      | Allen Memorial Hospital   |
      | Alta View Hospital        |
      | American Fork Hospital    |
    And I save the event
    And I navigate to the morbidity event edit page
    Then I should see all of the repeater core field config questions for each hospitalization
    When I navigate to the morbidity event show page
    Then I should see all of the repeater core field config questions for each hospitalization
     
  Scenario: Editing CMR with no core forms are applied, save multiple hospitalizations.
    Given I am logged in as a super user
    And a basic morbidity event exists
    When I navigate to the morbidity event edit page
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
    And I navigate to the morbidity event edit page
    Then I should see "Add a Hospitalization Facility"



