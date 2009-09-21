Feature: Notes can be added to an Event

  To aid tracking the history of an event, clinical and administrative
  notes can be added to an event.

  @clean
  Scenario: Event creation generates a note
    Given I am logged in as a super user
    When I go to the new CMR page
      And I fill in "Last name" with "Jones"
      And I press "Save & Continue"
      And I wait for the page to load
    Then I should see "Event created for jurisdiction Unassigned"
