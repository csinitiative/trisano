Feature: Export events for ibis

  In order to better analyze events
  As an administrator
  I need to be able to export data in a format compatible w/ ibis.

  Scenario: Export events Confirmed by the State
    Given a morbidity event with disease "African Tick Bite Fever" and "Confirmed" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml
