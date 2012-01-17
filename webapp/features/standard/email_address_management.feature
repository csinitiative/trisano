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
    When I fill in "Add an Email Address" with "user@example.com"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "user@example.com"

  Scenario: Attempting to add a blank e-mail address
    When I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "Error adding e-mail address"
    And I should see "Email address can't be blank"

  Scenario: Attempting to add an invalid e-mail address
    When I fill in "Add an Email Address" with "xyz"
    And I press "Add"
    Then I should be on the manage e-mail addresses page
    And I should see "Error adding e-mail address"
    And I should see "Email address format is invalid"

  Scenario: Deleting an e-mail address
    When I click the "Delete" link
    Then I should be on the manage e-mail addresses page
    And I should not see "foo@bar.com"

  Scenario: Editing an existing e-mail address
    When I follow "Edit"
    And I fill in "Email address" with "edited_email@email.com"
    And I press "Update"
    Then I should be on the manage e-mail addresses page
    And I should see "E-mail address successfully updated"

  Scenario: Editing an existing e-mail address with an invalid e-mail address
    When I follow "Edit"
    And I fill in "Email address" with "frmp"
    And I press "Update"
    Then I should see "Error updating e-mail address"
    And I should see "Email address format is invalid"

    When I fill in "Email address" with "edited_email@email.com"
    And I press "Update"
    Then I should be on the manage e-mail addresses page
    And I should see "E-mail address successfully updated"

