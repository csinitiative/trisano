Feature: Promoting Contact Events to Assessment Events

  So that I can better investigate a contact of a morbidity event
  As an investigator
  I want to change a contact event into a assessment event

  Scenario: Visiting contact show mode has 'promote' link
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact on the event named Jones
    And I am logged in as a super user

    When I am on the contact show page
    Then I should see a link to promote event to a AE

  Scenario: Contact changed and user redirected
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
      And I am logged in as a super user
     When I promote Jones to a assessment event
     Then I should be viewing the show assessment event for Jones page
      And I should see "Successfully promoted to assessment event."

  Scenario: Promoted assessment event displays parent and disease forms
    Given a published disease form called MA1 for assessment events with Mumps
    And a published disease form called CA1 for contact events with Mumps
    And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact on the event named Jones
    And I am logged in as a super user

    When I promote Jones to a assessment event
    Then the assessment event should have disease forms for MA1 and CA1
    And the new assessment event should show Smith as the parent

  Scenario: Parent morbiditity event shows Jones as being promoted
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact on the event named Jones
    And I am logged in as a super user

    When I promote Jones to a assessment event
    Then I should see "<b>Promoted</b> from <b>Contact event</b> to <b>Assessment event</b> on (.+) at (.+) by (.+)"
    And the parent CMR should show the child as an elevated assessment

  Scenario: Promoting a contact that has becom invalid
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
      And there is a contact on the event named Jones
      And the contact disease diagnosed date is invalid
      And I am logged in as a super user
     When I promote Jones to a assessment event
     Then I should see "Could not promote event."
      And I should see "Date diagnosed must be on or after"
