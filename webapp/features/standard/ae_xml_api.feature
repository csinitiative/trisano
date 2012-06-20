Feature: XML API for AEs

  Because other systems need to interact w/ TriSano
  As a developer
  I want to be able to programmatically access aes as XML

  Scenario: Accessing a AE XML representation
    Given a basic assessment event exists
     When I retrieve the AE XML representation for ae
     Then I should have an xml document
     When I use xpath to find the assessment event patient's last name
     Then I should have 1 node

  Scenario: Putting a AE back using the XML representation
    Given a basic assessment event exists
     When I retrieve the AE XML representation for ae
      And I PUT the XML back
     Then I should get a 200 response

  Scenario: Putting an invalid AE should returns errors
    Given a basic assessment event exists
    When I retrieve the AE XML representation for ae
    And I make the XML invalid
    And I PUT the XML back
    Then I should get a 422 response

  Scenario: Creating a AE from an XML representation
     When I retrieve the AE XML representation for new_ae
      And I replace the assessment event patient's last name with "Davis"
      And I replace the assessment event first reported to public health date with yesterday's date
      And I POST the XML to the "index" link
     Then I should get a 201 response
      And the Location header should have a link to the new assessment event

  Scenario: Adding a note to a AE
    Given a basic assessment event exists
    When I retrieve the AE XML representation for ae
    And I add "Updated from the API" as an administrative note
    And I PUT the XML back
    And I go to the AE show page
    Then I should see "Updated from the API"

  Scenario: Retrieve an edit_jurisdiction template
    Given a basic assessment event exists
    When I retrieve the AE XML representation for edit_jurisdiction_ae
    Then I should have an xml document
    And these xpaths should exist:
      | /routing/atom:link[@rel='route'][contains(@href, 'aes')]                                              |
      | /routing/atom:link[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction']       |
      | /routing/jurisdiction-id[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction'] |
      | /routing/note                                                                                          |

  Scenario: Route a AE to a jurisdiction
    Given a basic assessment event exists
    When I retrieve the AE XML representation for edit_jurisdiction_ae
    And I replace jurisdiction-id with jurisdiction "Bear River"
    And I replace the assignment note with "Hello, Bear River"
    And I POST the XML to the "route" link
    And I retrieve the AE XML representation for ae
    Then these xpaths should exist:
      | //jurisdiction-attributes                     |
      | //jurisdiction-attributes/secondary-entity-id |
    And I should see the new jurisdiction
    And these xpaths should exist:
      | //note[text()='Hello, Bear River'] |

  Scenario: Route a AE to an invalid jurisdiction
    Given a basic assessment event exists
    When I retrieve the AE XML representation for edit_jurisdiction_ae
    And I invalidate the jurisdiction
    And I POST the XML to the "route" link
    Then I should get a 422 response
    And I should see "Couldn't find PlaceEntity"

  Scenario: Add a task to a AE
    Given a basic assessment event exists
    When I retrieve the AE XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I POST the XML to the "index" link
    And I retrieve the AE XML representation for event_tasks
    Then these xpaths should exist:
      | /event-tasks/tasks/i0/name[text()='follow up'] |

  Scenario: Add a task with an assignable user to a AE as a privileged user
    Given a basic assessment event exists
    And I am logged in as a super user
    When I retrieve the AE XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I assign an assignable user to the task
    And I POST the XML to the "index" link
    Then I should get a 200 response

  Scenario: Add a task with an unassignable user to a AE as a privileged user
    Given a basic assessment event exists
    And I am logged in as a super user
    When I retrieve the AE XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I assign an unassignable user to the task
    And I POST the XML to the "index" link
    Then I should get a 422 response
    And I should see "Insufficient privileges"

  @pending
  Scenario: Add a task with a user to a AE as an unprivileged user
    Given a basic assessment event exists
    And I am logged in as an investigator
    When I retrieve the AE XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I assign any other user to the task
    And I POST the XML to the "index" link
    Then I should get a 422 response
