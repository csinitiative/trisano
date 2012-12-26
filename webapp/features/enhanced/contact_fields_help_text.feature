Feature: Contact event, viewing core field help text

  To better enable a user to fill in an event form
  An investigator should see help text on core fields

  @flush_core_fields_cache
  Scenario: Viewing contact event help text
    Given I am logged in as a super user
    And all core field configs for a contact event have help text
    And a basic morbidity event exists
    And there is a contact on the event named Contacto
    And a lab named "Labby"
    And a common test type named "Common Test Type"

    When I am on the contact event edit page
    Then I should see help text for all contact event core fields in edit mode

    When I fill in enough contact event data to enable all core fields to show up in show mode
    And I save and continue
    Then I should see help text for all contact event core fields in show mode
