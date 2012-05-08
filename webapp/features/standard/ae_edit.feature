Feature: Edit an assessment event

  Background:
    Given I am logged in as a super user
    And a basic assessment event exists
    And I am on the edit the AE page

  Scenario: Entering a diagnostic facility
    When I enter a diagnostic facility name and type
    And I enter a diagnostic facility address
    And I save the event
    Then I should see "AE was successfully updated"
    And I should see "Zed's Lab"

  Scenario: Entering a diagnostic facility address without a name
    When I enter a diagnostic facility address
    And I save the event
    Then I should see "Entity information is not complete"

  Scenario: Entering a place exposure
    When I enter a place exposure's name and type
    And I enter the place exposure's address
    And I save the event
    Then I should see "AE was successfully updated"

  Scenario: Entering a place exposure address without a name
    When I enter the place exposure's address
    And I save the event
    Then I should see "Entity information is not complete"
