Feature: Place event form core field configs

  To allow for a more relevant event form
  An investigator should see core field configs on a place form

  Scenario: Place event core field configs
    Given I am logged in as a super user
    And a place event form exists
    And that form has core field configs configured for all core fields
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And there is a place on the event named The Shack

    When I am on the place event edit page
    Then I should see all of the core field config questions

    When I answer all core field config questions
    And I save and continue
    Then I should see all of the core field config questions
    And I should see all core field config answers
