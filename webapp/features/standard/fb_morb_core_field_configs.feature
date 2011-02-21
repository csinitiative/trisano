Feature: Morbidity event form core field configs

  To allow for a more relevant event form
  An investigator should see core field configs on a moridity form

  Scenario: Morbidity event core field configs
    Given I am logged in as a super user
      And a morbidity event form exists
      And that form has core field configs configured for all core fields
      And that form is published
      And a morbidity event exists with a disease that matches the form
     When I am on the event edit page
      And I answer all core field config questions
      And I save the event
     Then I should see all of the core field config questions
      And I should see all core field config answers
