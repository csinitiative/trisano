Feature: An admin can select how to sort the list of users

  To simplify user management
  An admin should be able to sort users by various user attributes

  Scenario: Sorting the users by UID, ascending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    Then I should see "Users"
    And uid "lhd_mgr" should appear before uid "utah"

  Scenario: Sorting the users by UID, descending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    And I select "Descending" from "Direction"
    And I press "Sort"
    Then uid "utah" should appear before uid "lhd_mgr"
    And "Descending" should be selected from "sort_direction"

  Scenario: Sorting the users by Status, ascending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    And I select "Status" from "Sort by"
    And I select "Ascending" from "Direction"
    And I press "Sort"
    Then user status "Active" should not appear after user status "Disabled"
    And "Ascending" should be selected from "sort_direction"
    And "Status" should be selected from "sort_by"

