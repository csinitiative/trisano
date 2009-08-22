Feature: Creating and editing users

  To control and identify access to the system
  Admins need to be able to create and update users.

  Scenario: Viewing the user account
    Given I am logged in as a super user
    When I go to view the default user
    Then I should see "utah"

  Scenario: Creating a new user account
    Given I am logged in as a super user
    When I go to the new user page
    And I fill in "UID" with "joe"
    And I fill in "User name" with "Joseph"
    And I press "Create"
    Then I should see "User was successfully created"
    And I should see "joe"

  Scenario: Editing a user account
    Given I am logged in as a super user
    And I have a user with the UID "joe" and user name "joe@joe.com"
    When I go to edit the user
    And I fill in "First name" with "Joseph"
    And I press "Update"
    Then I should see "User was successfully updated"
    And I should see "Joseph"

  Scenario: Deleting the UID
    Given I am logged in as a super user
    And I have a user with the UID "joe" and user name "joe@joe.com"
    When I go to edit the user
    And I fill in "UID" with ""
    And I press "Update"
    Then I should see "Uid can't be blank"
