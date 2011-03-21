Feature: Managing roles and privileges

  In order to manage user access rights admins need to be able to view
  and edit permissions associated with roles

  Background:
    Given I am logged in as a super user

  Scenario: Viewing privileges associated with roles
    When I go to the edit "Administrator" role page
    Then I should see "Create staged messages"
     And I should see "Administer"
     And I should see "Add forms to events"

  Scenario: Creating a new role
    Given I am on the roles page
    When I press "Create New Role"
    And I fill in "Role Name" with "Junguar"
    And I check "Access AVR"
    And I check "View Events"
    And I check "Administer"
    And I press "Create"
    Then I should see "Role was successfully created"
    And I should see "Junguar"
    And I should see "Access AVR"
    And I should see "Administer"
    And I should see "View events"

  Scenario: Updating a role's privileges
    Given a role named "Junguar"
    And the role "Junguar" has the following privileges:
      | Administer |
      | Access AVR |
      | Update events |
    And I am on the edit "Junguar" role page
    When I uncheck "Update events"
    And I check "View events"
    And I press "Update"
    Then I should see "Role was successfully updated"
    And I should see "Administer"
    And I should see "Access AVR"
    And I should see "View events"
    And I should not see "Update events"

