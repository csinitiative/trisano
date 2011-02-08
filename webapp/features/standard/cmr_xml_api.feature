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
      And I put the XML back
     Then I should get a 200 response
