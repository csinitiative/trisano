Feature: Redirecting to site-configured analysis URL

  As a user
  In order for my keyboard shortcut to the AVR tools to work
  I must be redirected from /analysis to the site-configured AVR URL

  Scenario: Redirecting to site-configured analysis URL
    Given I am logged in as a super user
    When I am on the analysis page
    Then I should see "redirected"
