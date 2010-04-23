Feature: Add an investiagation tab

  In order to create orderly forms
  Form builders need to be able to place content on organized tabs

  Scenario: Adding a tab
    Given I am logged in as a super user
      And I already have a form with the name "Test form"
     When I add a tab named "Maternal Information"
     Then I should see "Maternal Information"
      And I should not see "translation missing"
