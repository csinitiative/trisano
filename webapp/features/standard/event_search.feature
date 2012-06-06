# Pending scenarios are because of a bug in in Webrat. Unpend when on Webrat >= 6.x
Feature: Searching for Events using core fields for criteria.

  To make finding and analyzing events easier
  As an investigator
  I want to be able to search for events based on a number of criteria

  Scenario: Searching for a morbidity event by record number
    Given a morbidity event with the record number 300000000000001
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I enter 300000000000001 into the record number search field
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for an assessment event by record number
    Given a assessment event with the record number 300000000000001
    And another assessment event
    And I am logged in as a super user

    When I navigate to the event search form
    And I enter 300000000000001 into the record number search field
    And I submit the search

    Then I should receive 1 matching assessment record

  Scenario: Searching for an event by pregancy status
    Given a morbidity event with a pregnant patient
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Yes" from "pregnant_id"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for an event by state case status
    Given a morbidity event with a state status "Confirmed"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Confirmed" from "State case status"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for an event by local health department status
    Given a morbidity event with a LHD status "Probable"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Probable" from "LHD case status"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for events sent to CDC
    Given a morbidity event that has been sent to the CDC
    And another morbidity event

    When I navigate to the event search form
    And I select "Yes" from "sent_to_cdc"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for events by date first reported to public health
    Given a morbidity event first reported on "December 12th, 2008"
    And a morbidity event first reported on "January 1st, 2009"
    And I am logged in as a super user

    When I navigate to the event search form
    And I fill in "first_reported_PH_date_start" with "12/13/2008"
    And I fill in "first_reported_PH_date_end" with "1/2/2009"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for events by investigator
    Given a morbidity event investigated by "investigator"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "investigator" from "Investigated by"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for events by 'other data 1' field
    Given a morbidity event with "other_data_1" set to "blah"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I fill in "other_data_1" with "blah"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for events by 'other data 2' field
    Given a morbidity event with "other_data_2" set to "blah"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I fill in "other_data_2" with "blah"
    And I submit the search

    Then I should receive 1 matching CMR record

  Scenario: Searching for an event w/ fulltext
    Given a simple morbidity event in jurisdiction Unassigned for last name Jones
      And a simple morbidity event in jurisdiction Unassigned for last name Joans
      And another morbidity event
      And I am logged in as a super user
     When I search for events with the following criteria:
       | name  |
       | Jones |
     Then I should see "Jones"
      And I should see "Joans"
      And I should not see "There was a problem with your search criteria"

  Scenario: Searching for an events should limit results to configured max
    Given max_search_results + 1 basic morbidity events
     When I search for events with the following criteria:
       | event_type     |
       | MorbidityEvent |
     Then I should see max_search_results records returned
      And I should see "Your data export request exceeds the allowed size limit for a real-time request."

  Scenario: Searching for an event w/ fulltext where the patient has a middle name
    Given a simple morbidity event in jurisdiction Unassigned for the full name of Robert Jack Jones
      And a simple morbidity event in jurisdiction Unassigned for last name Joans
      And another morbidity event
      And I am logged in as a super user
     When I search for events with the following criteria:
       | name  |
       | Jones |
     Then I should see "Jones, Robert Jack"
