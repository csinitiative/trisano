Feature: Searching for Events using core fields for criteria.

  To make finding and analyzing events easier
  As an investigator
  I want to be able to search for events based on a number of criteria

  Scenario: Searching for an event by record number.
    Given a morbidity event with the record number 300000000000001
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I enter 300000000000001 into the record number search field
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for an event by pregancy status.
    Given a morbidity event with a pregnant patient
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Yes" from "pregnancy_status"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for an event by state case status
    Given a morbidity event with a state status "Confirmed"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Confirmed" from "state_status"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for an event by local health department status
    Given a morbidity event with a LHD status "Probable"
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I select "Probable" from "lhd_status"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for events sent to CDC
    Given a morbidity event that has been sent to the CDC
    And another morbidity event

    When I navigate to the event search form
    And I select "Yes" from "sent_to_cdc"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for events by date first reported to public health
    Given a morbidity event first reported on "December 12th, 2008"
    And a morbidity event first reported on "January 1st, 2009"
    And I am logged in as a super user

    When I navigate to the event search form
    And I fill in "first_reported_PH_date_start" with "12/13/2008"
    And I fill in "first_reported_PH_date_end" with "1/2/2009"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for events by investigator
    Given an investigator named Davis
    And a morbidity event investited by Davis
    And another morbidity even
    And I am logged in as super user

    When I navigate to the event search form
    And I select "Davis" from "investigator_field"
    And I submit the search

    Then I should receive 1 matching record.

  Scenario: Searching for events by 'other data 1' field
    Given a morbidity event with 'blah' in other data 1
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I enter "blah" into "other_data_1"
    And I submit the search

    Then I should receive 1 matching record

  Scenario: Searching for events by 'other data 2' field
    Given a morbidity event with 'blah' in other data 1
    And another morbidity event
    And I am logged in as a super user

    When I navigate to the event search form
    And I enter "blah" into "other_data_1"
    And I submit the search

    Then I should receive 1 matching record


