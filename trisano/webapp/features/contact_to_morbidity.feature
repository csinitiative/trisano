Feature: Promoting Contact Events to Morbidity Events

  So that I can better investigate a contact of a morbidity event
  As an investigator
  I want to change a contact event into a morbidity event

  Scenario: Visiting contact show mode has 'promote' link
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact named Jones
    And I am logged in as a super user

    When I visit contacts show page
    Then I should see a link to promote event to a CMR

  Scenario: Contact changed and user redirected
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact named Jones
    And I am logged in as a super user

    When I promote Jones to a morbidity event
    Then I should be on the show morbidity event for Jones page

  Scenario: Promoted morbidity event displays parent and disease forms
    Given a published disease form called MA1 for morbidity events with Mumps
    And a published disease form called CA1 for contact events with Mumps
    And a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact named Jones
    And I am logged in as a super user

    When I promote Jones to a morbidity event
    Then the morbidity event should have disease forms for MA1 and CA1
    And the new morbidity event should show Smith as the parent
    
  Scenario: Parent morbiditity event shows Jones as being promoted
    Given a morbidity event for last name Smith with disease Mumps in jurisdiction Davis County
    And there is a contact named Jones
    And I am logged in as a super user

    When I promote Jones to a morbidity event
    Then the parent CMR should show the child as an elevated contact
