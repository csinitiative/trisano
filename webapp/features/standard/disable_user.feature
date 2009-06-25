Feature: Disable user logon

  So that I can prevent a user from logging into the system
  I want to have a toggle option that enforces this

  Scenario: Admin disables a user logon
    Given I am logged in as a super user
    When I go to the investigator user edit page
    And I see that the user is not yet disabled
    And I check "user_disable"
    And I press "update"
    And I go to the investigator user edit page
    Then the disable checkbox should still be checked

  Scenario: Disabled user attempts to login
    Given I am logged in as a disabled user
    Then I am presented with a page saying that the account is not available
