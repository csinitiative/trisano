Feature: Events can be deep copied

  Because many reportable conditions are related, Epi's need to be
  able to create deep copies of existing Morbidity events.

  Scenario: Copying an event, including Clincal information
    Given I am logged in as a super user
      And a morbidity event with record number "20071"
    When I go to show the CMR with record number "20071"
      And I check "Clinical information (without disease)"
      And I press "Create and Edit Deep Copy"
    Then I should see "CMR was successfully created."
      And I should have a note that says "Event derived from"
      And I should see a link to "Event 20071"

  Scenario: Copying an event, including notes
    Given I am logged in as a super user
      And a basic morbidity event exists
      And the event has a clinical note authored by "default_user"
     When I go to view the CMR
      And I check "Notes"
      And I press "Create and Edit Deep Copy"
     Then I should see "CMR was successfully created"
      And I should have a note that says "Event derived from"
      And I should see a clinical note from "default_user"
