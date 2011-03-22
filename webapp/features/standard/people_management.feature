Feature: Managing people entities

  Scenario: Editing an existing person
    Given I am logged in as a super user
    And a person named "Less Nessman" exists
    When I go to edit the person "Less Nessman"
    Then I should not see errors on the "Email address" field
