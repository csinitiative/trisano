Feature: Editing places

  To enable seed the system with places
  As an admin
  I want to be able to create a place

  Scenario: Creating a place
    Given I am logged in as a super user
    When I am on the places page
    And I press "Create new place"
    And I fill in "Name" with "A new place"
    And I check "Pool"
    And I enter a canonical address
    And I press "Create"
    Then I should be on the "A new place" place show page
    And I should see "Place was successfully created"
    And I should see "Pool"
    And I should see "Happy St."

  Scenario: Creating a place with invalid information
    Given I am logged in as a super user
    When I am on the places page
    And I press "Create new place"
    And I check "Pool"
    And I press "Create"
    Then I should be on the places page
    And I should see "Place name can't be blank"


