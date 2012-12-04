Feature: Morbidity event form core follow ups

  To allow for a more relevant event form
  An investigator should see core follow ups configured on a moridity form

  Scenario: Morbidity event core follow ups
    Given I am logged in as a super user
    And a morbidity event form exists
    And that form has core follow ups configured for all core fields
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And I am on the morbidity event edit page
    And I don't see any of the core follow up questions

    When I answer all of the core follow ups with a matching condition
    Then I should see all of the core follow up questions

    When I answer all core follow up questions
    And I save and continue
    Then I should see all of the core follow up questions
    And I should see all follow up answers

    When I am on the morbidity event edit page
    And I remove read only entities from the event
    And I answer all of the core follow ups with a non-matching condition
    Then I should not see any of the core follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the core follow up questions
    And I should not see any follow up answers

