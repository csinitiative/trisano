Feature: Change expired password

  To change expired password
  A user interface is needed that can handle password change

  Scenario: Logging in with good credentials and expired password
    Given I am not logged in
     When I go to the login page
      And I login with expired password
     Then I should see "Change Password"
      And I should be on the change password page

  Scenario: Logged in with expired password popup
    Given I am logged in as a super user
     When My password expires
      And I go to the dashboard page
     Then I should see "Your password has expired."

#  Scenario: Trying to access change password page without logging in
#    Given I am not logged in
#     When I go to the change password page
#     Then I should be on the login page

  Scenario: Trying to access change password page while logged in
    Given I am logged in as a super user
     When I go to the change password page
     Then I should be on the change password page