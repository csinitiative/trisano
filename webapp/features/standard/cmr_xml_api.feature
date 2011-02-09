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

  Scenario: Creating a CMR from an XML representation
     When I retrieve a new CMR xml representation
      And I replace the patient's last name with "Davis"
      And I replace the first reported to public health date with yesterday's date
      And I POST the XML to the collection
     Then I should get a 201 response
      And the Location header should have a link to the new event
