Feature: XML API for Contact Events

  Because other systems need to interact w/ TriSano
  As a developer
  I want to be able to programmatically access contact events as XML

  Scenario: Retrieve an edit_jurisdiction template
    Given there is a contact event
    When I retrieve the contact event XML representation for edit_jurisdiction_contact_event
    Then I should have an xml document
    And these xpaths should exist:
      | /routing/atom:link[@rel='route'][contains(@href, 'contact_events')]                                    |
      | /routing/atom:link[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction']       |
      | /routing/jurisdiction-id[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction'] |
      | /routing/note                                                                                          |

  Scenario: Route a contact event to a jurisdiction
    Given there is a contact event
    When I retrieve the contact event XML representation for edit_jurisdiction_contact_event
    And I replace jurisdiction-id with jurisdiction "Bear River"
    And I replace the assignment note with "Routed in a cuke"
    And I POST the XML to the "route" link
    And I view the HTML contact event page
    Then I should see "Bear River"
    And I should see "Routed in a cuke"

  Scenario: Add a task to a contact event
    Given there is a contact event
    When I retrieve the contact event XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I POST the XML to the "index" link
    And I view the HTML contact event page
    Then I should see "follow up"

  Scenario: Add a task with an assigned user to a contact event as a privileged user
    Given there is a contact event
    And I am logged in as a super user
    When I retrieve the contact event XML representation for new_event_task
    And I replace the task name with "follow up"
    And I replace the task due date with tomorrow's date
    And I POST the XML to the "index" link
    Then I should get a 200 response
