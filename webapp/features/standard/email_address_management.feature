Feature: Managing user e-mail addresses

  Because I want to be alerted by e-mail of important system events
  As a user of TriSano
  I want to associate a list of e-mail addresses with my user account

  Background:
    Given I am logged in as a super user
    And I have the following email addresses:
      | foo@bar.com |
    When I go to the manage e-mail addresses page

  Scenario: Adding an e-mail address
    When I fill in "email_address" with "user@example.com"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "user@example.com"

  Scenario: Attempting to add a blank e-mail address
    When I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "Error adding e-mail address"

  Scenario: Attempting to add an invalid e-mail address
    When I fill in "email_address" with "xyz"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "Error adding e-mail address"
    And I should not see "xyz"

  Scenario: Attempting to add a duplicate e-mail address
    When I fill in "email_address" with "foo@bar.com"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "Error adding e-mail address"

  Scenario: Deleting an e-mail address
    When I click the "Delete" link
    Then I should be on the manage e-mail addresses page
    And I should not see "foo@bar.com"
