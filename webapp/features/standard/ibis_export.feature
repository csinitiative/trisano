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

  Scenario: Export events Suspect by the State
    Given a morbidity event with disease "African Tick Bite Fever" and "Suspect" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml

  Scenario: Export events Probable by the State
    Given a morbidity event with disease "African Tick Bite Fever" and "Probable" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml

  Scenario: Export events Not a case by the State
    Given a morbidity event with disease "African Tick Bite Fever" and "Not a Case" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml
    And I should see "4" in the "Status" node

  Scenario: Export events Unknown by the State
    Given a morbidity event with disease "African Tick Bite Fever" and "Unknown" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml
    And I should see "9" in the "Status" node

  Scenario: Export events with a county code
    Given a morbidity event in "Morgan" county, with disease "African Tick Bite Fever" and "Confirmed" by the state
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button

    Then I should receive the morbidity event as xml
    And I should see "15" in the "County" node

  Scenario: Export events Confirmed by the LHD
    Given a morbidity event with disease "African Tick Bite Fever" and "Confirmed" by the LHD
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button
    
    Then I should receive the morbidity event as xml

  Scenario: Event onset date code is present
    Given a morbidity event with disease "African Tick Bite Fever" and disease date "2011/05/15"
    And I am logged in as a super user

    When I navigate to the ibis export form
    And I set the "start_date" to "yesterday"
    And I set the "end_date" to "tomorrow"
    And I click the "submit" button

    Then I should receive the morbidity event as xml
    And I should see "2011-05-15" in the "EventOnsetDate" node


    
