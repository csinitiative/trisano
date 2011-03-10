Feature: Managing user e-mail addresses

  Because I want to be alerted by e-mail of important system events
  As a user of TriSano
  I want to associate a list of e-mail addresses with my user account

  Scenario: Adding an e-mail address
    Given I am logged in as a super user
    When I go to the manage e-mail addresses page
    And I fill in "email_address" with "user@example.com"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "user@example.com"
