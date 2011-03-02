Feature: XML API for Contact Events

  Because other systems need to interact w/ TriSano
  As a developer
  I want to be able to programmatically access contact events as XML

  Scenario: Retrieve an edit_jurisdiction template
    Given there is a contact event
    When I retrieve the edit_jurisdiction contact event XML representation
    Then I should have an xml document
    And these xpaths should exist:
      | /routing/atom:link[@rel='route'][contains(@href, 'contact_events')]                                    |
      | /routing/atom:link[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction']       |
      | /routing/jurisdiction-id[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction'] |
      | /routing/note                                                                                          |

  @pending
  Scenario: Route a contact event to a jurisdiction
    Given there is a contact event
    When I retrieve the edit_jurisdiction contact event XML representation
    And I replace jurisdiction-id with jurisdiction "Bear River"
    And I add the assignment note "Hello, Bear River"
    And I POST the XML to the "route" link
    And I retrieve the contact event's XML representation
    Then these xpaths should exist:
      | //jurisdiction-attributes                     |
      | //jurisdiction-attributes/secondary-entity-id |
    And I should see the new jurisdiction
    And I should see "Hello, Bear River"
