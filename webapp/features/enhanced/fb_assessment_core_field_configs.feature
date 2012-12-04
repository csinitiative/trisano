Feature: assessment event form core field configs

  To allow for a more relevant event form
  An investigator should see core field configs on a moridity form

  Scenario: assessment event core field configs
    Given I am logged in as a super user
    And a lab named "Labby"
    And a assessment event form exists
    And that form has core field configs configured for all core fields
    And that form is published
    And a assessment event exists with a disease that matches the form
    When I am on the assessment event edit page
     And I fill in enough assessment event data to enable all core fields to show up in show mode
     And I save and continue
    Then I should see all of the core field config questions

    When I answer all core field config questions
    And I save and continue
    Then I should see all of the core field config questions
    And I should see all core field config answers
