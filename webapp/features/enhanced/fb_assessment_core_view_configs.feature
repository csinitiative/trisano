Feature: assessment event form core view configs

  To allow for a more relevant event form
  An investigator should see core view configs on a moridity form

  Scenario: assessment event core view configs
    Given I am logged in as a super user
    And a assessment event form exists
    And that form has core view configs configured for all core views
    And that form is published
    And a assessment event exists with a disease that matches the form
    When I am on the assessment event edit page
    Then I should see all of the core view config questions

    When I answer all core view config questions
    And I save and continue
    Then I should see all of the core view config questions
    And I should see all core view config answers
