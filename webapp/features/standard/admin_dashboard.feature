Feature: The administration dashboard

  To simplify navigation through administration functions
  An administation dashboard was created

  Scenario: An non-administrator tries to access the admin dashboard
    Given I am logged in as an investigator
    When I go to the admin dashboard
    Then I should get a 403 response

  Scenario: An administrator accesses the admin dashboard
    Given I am logged in as a super user
    When I go to the admin dashboard

    Then I should see a link to "Manage Users"
    And I should see a link to "Manage Common Test Types"
