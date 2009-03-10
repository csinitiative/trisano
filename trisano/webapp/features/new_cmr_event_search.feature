Feature: Searching for existing people or events before adding a CMR

  So that I can avoid duplicate data entry
  As an investigator
  I want to search for existing people or events before adding a new CMR

  Scenario: Clicking 'NEW CMR' link brings up a search form
    Given I am logged in as a super user

    When I click the "NEW CMR" link
    Then I should see a search form
    And I should not see a link to enter a new CMR

  Scenario: Searching for a person uses soundex
    Given a simple morbidity event for last name Jones
    And a simple morbidity event for last name Joans
    And I am logged in as a super user

    When I search for "Jones"
    Then I should see results for Jones and Joans
    And the search field should contain Jones

  Scenario: Searches include contact and morbidity events
    Given a simple morbidity event for last name Jones
    And there is a contact named Jones
    And I am logged in as a super user

    When I search for "Jones"
    Then I should see results for both records
    
  Scenario: Disease is hidden from people without the right privileges
    Given a morbidity event for last name Jones with disease Mumps in jurisdiction Davis County
    And I am logged in as a user without view or update privileges in Davis County

    When I search for "Jones"
    Then the disease should show as 'private'
