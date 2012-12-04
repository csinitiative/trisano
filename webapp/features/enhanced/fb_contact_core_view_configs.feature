Feature: Contact event form core view configs

  To allow for a more relevant event form
  An investigator should see core view configs on a contact form

  Scenario: Contact event core view configs
    Given I am logged in as a super user
    And a contact event form exists
    And that form has core view configs configured for all core views
    And that form is published
    And a morbidity event exists with a disease that matches the form
    And there is a contact on the event named Contacto
    When I am on the contact event edit page
    Then I should see all of the core view config questions

    When I answer all core view config questions
    And I save and continue
    Then I should see all of the core view config questions
    And I should see all core view config answers
