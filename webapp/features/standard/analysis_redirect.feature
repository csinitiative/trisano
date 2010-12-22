Feature: Adding forms to events

  Scenario: Morbidity event form add as admin
    Given I am logged in as a super user
    When I am on the analysis page
    Then I should see "redirected"
