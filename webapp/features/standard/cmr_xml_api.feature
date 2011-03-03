Feature: XML API for CMRs

  Because other systems need to interact w/ TriSano
  As a developer
  I want to be able to programmatically access cmrs as XML

  Scenario: Accessing a CMR XML representation
    Given a basic morbidity event exists
     When I retrieve the event's XML representation
     Then I should have an xml document
     When I use xpath to find the patient's last name
     Then I should have 1 node

  Scenario: Putting a CMR back using the XML representation
    Given a basic morbidity event exists
     When I retrieve the event's XML representation
      And I PUT the XML back
     Then I should get a 200 response

  Scenario: Putting an invalid CMR should returns errors
    Given a basic morbidity event exists
    When I retrieve the event's XML representation
    And I make the XML invalid
    And I PUT the XML back
    Then I should get a 422 response

  Scenario: Creating a CMR from an XML representation
     When I retrieve a new CMR xml representation
      And I replace the patient's last name with "Davis"
      And I replace the first reported to public health date with yesterday's date
      And I POST the XML to the "index" link
     Then I should get a 201 response
      And the Location header should have a link to the new event

  Scenario: Adding a note to a CMR
    Given a basic morbidity event exists
    When I retrieve the event's XML representation
    And I add "Updated from the API" as an administrative note
    And I PUT the XML back
    And I go to the CMR show page
    Then I should see "Updated from the API"

  Scenario: Retrieve an edit_jurisdiction template
    Given a basic morbidity event exists
    When I retrieve the edit_jurisdiction CMR XML representation
    Then I should have an xml document
    And these xpaths should exist:
      | /routing/atom:link[@rel='route'][contains(@href, 'cmrs')]                                              |
      | /routing/atom:link[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction']       |
      | /routing/jurisdiction-id[@rel='https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction'] |
      | /routing/note                                                                                          |

  Scenario: Route a CMR to a jurisdiction
    Given a basic morbidity event exists
    When I retrieve the edit_jurisdiction CMR XML representation
    And I replace jurisdiction-id with jurisdiction "Bear River"
    And I add the assignment note "Hello, Bear River"
    And I POST the XML to the "route" link
    And I retrieve the event's XML representation
    Then these xpaths should exist:
      | //jurisdiction-attributes                     |
      | //jurisdiction-attributes/secondary-entity-id |
    And I should see the new jurisdiction
    And I should see "Hello, Bear River"

  Scenario: Route a CMR to an invalid jurisdiction
    Given a basic morbidity event exists
    When I retrieve the edit_jurisdiction CMR XML representation
    And I invalidate the jurisdiction
    And I POST the XML to the "route" link
    Then I should get a 400 response
