Feature: Contact event form core follow ups

  To allow for a more relevant event form
  An investigator should see core follow ups configured on a contact form

  Scenario: Contact event core follow ups
    Given I am logged in as a super user
    And a contact event form exists
    And that form has core follow ups configured for all core fields
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And there is a contact on the event named Contacto
    And I am on the contact event edit page
    And I don't see any of the core follow up questions

    When I answer all of the core follow ups with a matching condition
    Then I should see all of the core follow up questions

    When I answer all core follow up questions
    And I save and continue
    Then I should see all of the core follow up questions
    And I should see all follow up answers

    When I am on the contact event edit page
    And I answer all of the core follow ups with a non-matching condition
    Then I should not see any of the core follow up questions
    And I should not see any follow up answers

    When I save and continue
    Then I should not see any of the core follow up questions
    And I should not see any follow up answers

