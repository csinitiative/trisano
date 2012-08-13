Feature: Managing user roles

  To control access to the system
  Admins need to be able to manage user access.

  @clean_user
  Scenario: Add a role to a user
    Given I am logged in as a super user
    And I have a user with the UID "jane" and user name "jane@jane.com"

    When I go to edit the user
    And I click the "Add Role" link and wait to see "Jurisdiction"
    And I select "Bear River Health Department" from "Jurisdiction"
    And I select "Investigator" from "Role"
    And I click the "Update" button
    And I wait for the page to load

    Then I should see "User was successfully updated"
    And I should see "Bear River Health Department"
    And I should see "Investigator"

  @clean_user
  Scenario: Remove a role from a user
    Given I am logged in as a super user
    And I have a user with the UID "jane" and user name "jean@jane.com"
    And the user has the role "Investigator" in the "Bear River Health Department"

    When I go to edit the user
    And I remove the role
    And I click the "Update" button
    And I wait for the page to load

    Then I should see "User was successfully updated"
    And I should not see "Bear River Health Department"
    And I should see "No roles."

  @clean_user
  Scenario: Removing a new role w/out updating
    Given I am logged in as a super user
    And I have a user with the UID "jane" and user name "jane@jane.com"

    When I go to edit the user
    And I click the "Add Role" link and wait to see "Jurisdiction"
    And I remove the role

    Then I should not see "Jurisdiction"
