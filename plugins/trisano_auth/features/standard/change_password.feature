@auth
Feature: Change expired password

  To change expired password
  A user interface is needed that can handle password change

  Scenario: Logging in with good credentials and expired password
    Given I am not logged in
      And Password expiry date is 90 days
     When I go to the login page
      And I login with expired password
     Then I should see "Your password has expired."

  Scenario: Logged in with password about to expire
    Given I am not logged in
      And Password expiry date is 90 days
     When I go to the login page
      And I login with password about to expire
     Then I should be on the dashboard page
      And I should see "Your password will expire"

  Scenario: Trying to access change password page while not logged in
    Given I am not logged in
     When I go to the change password page
     Then I should be on the login page