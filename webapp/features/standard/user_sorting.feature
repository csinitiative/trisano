Feature: An admin can select how to sort the list of users

  To simplify user management
  An admin should be able to sort users by various user attributes

  Scenario: Sorting the users by UID, ascending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    Then I should see "Users"
    And uid "lhd_mgr" should appear before uid "state_mgr"

  Scenario: Sorting the users by UID, descending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    And I select "Descending" from "Direction"
    And I press "Sort"
    Then uid "state_mgr" should appear before uid "lhd_mgr"
    And "Descending" should be selected from "sort_direction"

  Scenario: Sorting the users by Status, ascending
    Given the default system users
    And I am logged in as a super user
    And user "investigator" is disabled
    When I go to the users index page
    And I select "Status" from "Sort by"
    And I select "Ascending" from "Direction"
    And I press "Sort"
    Then I should see "Active"
    And I should see "Disabled"
    And user status "Active" should not appear after user status "Disabled"
    And "Ascending" should be selected from "sort_direction"
    And "Status" should be selected from "sort_by"

  Scenario: Sorting the users by Status, descending
    Given the default system users
    And I am logged in as a super user
    And user "investigator" is disabled
    When I go to the users index page
    And I select "Status" from "Sort by"
    And I select "Descending" from "Direction"
    And I press "Sort"
    Then I should see "Active"
    And I should see "Disabled"
    And user status "Disabled" should not appear after user status "Active"

  Scenario: Sorting by user name
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    And I select "User name" from "Sort by"
    And I select "Ascending" from "Direction"
    And I press "Sort"
    Then I should see "data_entry_tech"
    And I should see "surveillance_mgr"
    And user name "data_entry_tech" should not appear after user name "surveillance_mgr"

  Scenario: Sorting by user name, descending
    Given the default system users
    And I am logged in as a super user
    When I go to the users index page
    And I select "User name" from "Sort by"
    And I select "Descending" from "Direction"
    And I press "Sort"
    Then I should see "data_entry_tech"
    And I should see "surveillance_mgr"
    And user name "surveillance_mgr" should not appear after user name "data_entry_tech"
