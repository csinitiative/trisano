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
    And I fill in "Area code" with "111"
    And I fill in "Phone number" with "2223333"
    And I fill in "Extension" with "4"
    And I press "Create"
    Then I should be on the "A new place" place show page
    And I should see "Place was successfully created"
    And I should see "Pool"
    And I should see "Happy St."
    And the phone number should be displayed on the show page

  Scenario: Creating a place with invalid information
    Given I am logged in as a super user
    When I am on the places page
    And I press "Create new place"
    And I check "Pool"
    And I press "Create"
    Then I should be on the places page
    And I should see "Name can't be blank"


