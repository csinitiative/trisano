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

  Scenario: Export events with a county code
    Given a morbidity event in "Morgan" county, with disease "African Tick Bite Fever" and "Confirmed" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button

    Then I should receive the morbidity event as xml
    And it should have the code for "Morgan" county

  Scenario: Export events Confirmed by the LHD
    Given a morbidity event with disease "African Tick Bite Fever" and "Confirmed" by the LHD
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml

  Scenario: Export events that have been deleted from IBIS
    Given a morbidity event already sent to ibis, with an "Unconfirmed" LHD status
    And I am logged in as a super user
    
    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button

    Then I should receive the deleted morbidity event as xml
