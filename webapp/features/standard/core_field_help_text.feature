Feature: Help text is available for all core fields

  To make it easier to train new users
  Administrators can add help text to each of the core fields

  Scenario: Viewing help text on morbidity event core fields
    Given I am logged in as a super user
      And all core field configs for a morbidity event have help text
      And a morbidity event exists with a lab result having test type 'Chest X-ray'
     When I am on the event edit page
     Then I should see help text for all morbidity event core fields

  Scenario: Viewing help text on contact event core fields
    Given I am logged in as a super user
      And all core field configs for a contact event have help text
      And a basic morbidity event exists
      And there is a contact on the event named "Wilson"
     When I am on the contact event edit page
     Then I should see help text for all contact event core fields

  Scenario: Viewing help text on place event core fields
    Given I am logged in as a super user
      And all core field configs for a place event have help text
      And a basic morbidity event exists
      And there is a place on the event named "McW"
     When I am on the place event edit page
     Then I should see help text for all place event core fields

  Scenario: Viewing help text on encounter event core fields
    Given I am logged in as a super user
      And all core field configs for a encounter event have help text
      And a basic morbidity event exists
      And there is an associated encounter event
     When I am on the encounter event edit page
     Then I should see help text for all encounter event core fields
