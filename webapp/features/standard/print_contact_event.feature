Feature: Printer friendly contact events

  To better be able to review cases
  An ivestigator
  Needs to be able to print contact events in a readable format

  Scenario: Printing a contact event
    Given I am logged in as a super user
    And an existing contact event
    
    When I print the contact event
    
    Then I should see the demographics data
    And I should see clinical data
    And I should see lab data
    And I should see epi data
    And I should see admin data
    And I should see answer data
    
