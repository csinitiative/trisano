Feature: Printer friendly contact events

  To better be able to review cases
  An ivestigator
  Needs to be able to print contact events in a readable format

  Scenario: Printing a contact event
    Given I am logged in as a super user
    And I have an existing contact event
    
    When I print the contact event
    
    Then I should see the demographics data
    And I should see clinical data
    And I should see lab data
    And I should see epi data
    And I should see admin data
    And I should see answer data

  Scenario: Provide a way to preint contact from show mode
    Given I am logged in as a super user
    And I have an existing contact event

    When I visit the contacts show page
    
    Then I should see a link to print the event
