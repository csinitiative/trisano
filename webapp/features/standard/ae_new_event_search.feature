Feature: Searching for existing people or events before adding a AE

  So that I can avoid duplicate data entry
  As an investigator
  I want to search for existing people or events before adding a new AE 
 
  Scenario: Clicking 'NEW AE' link brings up a search form
    Given I am logged in as a super user
    When I click the "NEW AE" link
    Then I should see an assessment event search form
    And I should not see a link to enter a new AE
 
