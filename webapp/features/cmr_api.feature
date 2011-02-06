Feature: XML API for CMRs

  Because other systems need to interact w/ TriSano
  As a developer
  I want to be able to programmatically access cmrs as XML

  Scenario: Accessing a CMR XML representation
    Given a basic morbidity event exists
     When I retrieve the event's XML representation
     Then I should have an xml document
