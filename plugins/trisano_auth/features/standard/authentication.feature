Feature: Authentication

  To authenticate users
  A user interface is needed that can handle user authentication

  Scenario: Logging in with good credentials
    Given I am not logged in
     When I go to the login page
      And I login with good credentials
     Then I should see "LOG OUT"
      And I should be on the dashboard page

  Scenario: Logging in with bad password
    Given I am not logged in
     When I go to the login page
      And I login with a bad password
     Then I should be on the user sessions page

Scenario: Logging in with bad user name
    Given I am not logged in
     When I go to the login page
      And I login with a bad user name
     Then I should be on the user sessions page

  Scenario: Logging in twice in a row
    Given I am not logged in
     When I go to the login page
      And I login with good credentials
      And I go to the login page
     Then I should be on the login page

  Scenario: Logging out
    Given I am not logged in
     When I go to the login page
      And I login with good credentials
      And I follow "LOG OUT"
     Then I should be on the login page

  Scenario: Trying to access the site without logging in
    Given I am not logged in
     When I go to the dashboard page
     Then I should be on the login page