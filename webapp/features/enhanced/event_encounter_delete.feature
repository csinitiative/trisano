Feature: Removing existing encounter strikes them through

  To track encounters after they are deleted
  As an Investigator
  I want to be able to delete an encounter
  And have it still shown up, but struck-through on the parent record

  Scenario: Deleting an encounter for morbidity event
    Given a basic morbidity event exists
    And the event has an encounter
    And the encounter investigator is "joe" 
    When I navigate to the morbidity event show page
    When I click the "Show Encounter" link
    And I click the "Delete" link and accept the confirmation
    Then I should see "The event was successfully marked as deleted."
    When I click the encounter parent link
    Then the encounter should be struck-through

  Scenario: Deleting an encounter for an assessment event
    Given a basic assessment event exists
    And the event has an encounter
    And the encounter investigator is "joe" 
    When I navigate to the assessment event show page
    When I click the "Show Encounter" link
    And I click the "Delete" link and accept the confirmation
    Then I should see "The event was successfully marked as deleted."
    When I click the encounter parent link
    Then the encounter should be struck-through
