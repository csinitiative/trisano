Feature: Promoting Assessment Events to Morbidity Events

  So that I can better investigate an assessment event
  As an investigator
  I want to change an assessment event into a morbidity event

  Scenario: Visiting assessment show mode has 'promote' link
    Given a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
    And I am logged in as a super user

    When I am on the AE show page
    Then I should see a link to promote event to a CMR from an assessment

  Scenario: assessment changed and user redirected
    Given a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And I am logged in as a super user
     When I promote Jones assessment to a morbidity event
     Then I should be viewing the show morbidity event for Jones assessment page
      And I should see "Successfully promoted to CMR."

  Scenario: Promoted morbidity event displays disease forms
    Given a published disease form called MA1 for morbidity events with Mumps
    And a published disease form called CA1 for assessment events with Mumps
    And a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
    And I am logged in as a super user

    When I promote Jones assessment to a morbidity event
    Then the morbidity event should have disease forms for MA1 and CA1

  Scenario: Parent morbiditity event shows Jones as being promoted
    Given a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
    And I am logged in as a super user

    When I promote Jones assessment to a morbidity event
    Then I should see "<b>Promoted</b> from <b>Assessment event</b> to <b>Morbidity event</b> on (.+) at (.+) by (.+)"

  Scenario: Promoting an assessment that has becom invalid
    Given a assessment event for last name Smith with disease Mumps in jurisdiction Davis County
      And the event disease diagnosed date is invalid
      And I am logged in as a super user
     When I promote Jones assessment to a morbidity event
     Then I should see "Could not promote to morbidity event"
      And I should see "Date diagnosed must be on or after"
