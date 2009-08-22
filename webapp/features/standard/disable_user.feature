Feature: Disable user logon

  So that I can prevent a user from logging into the system
  I want to have a toggle option that enforces this

  Scenario: Admin disables a user logon
    Given I am logged in as a super user
    When I go to the investigator user edit page
    And I see that the user is not yet disabled
    And I select "Disabled" from "Status"
    And I press "Update"
    And I go to the investigator user edit page
    Then "Disabled" should be selected from "user_status"

  Scenario: Disabled user attempts to login
    Given I am logged in as a disabled user
    Then I am presented with a page saying that the account is not available
