Feature: Help text is available for all core fields

  To make it easier to train new users
  Administrators can add help text to each of the core fields

  Background:
    Given all core fields have help text


  Scenario: Administrator adds help text to core field
    Given I am logged in as a super user
    And a assessment event exists with a lab result having test type 'Chest X-ray'
    When I edit a assessment event core field and add help text that says 'Please capitalize patient first name'
    Then I should see "Please capitalize patient first name"
    When I am on the assessment event edit page
    Then I should see "Please capitalize patient first name"

  Scenario: Viewing help text on morbidity event core fields
    Given I am logged in as a super user
      And a morbidity event exists with a lab result having test type 'Chest X-ray'
     When I am on the morbidity event edit page
     Then I should see help text for all morbidity event core fields

  Scenario: Viewing help text on assessment event core fields
    Given I am logged in as a super user
      And a assessment event exists with a lab result having test type 'Chest X-ray'
     When I am on the assessment event edit page
     Then I should see help text for all assessment event core fields

  Scenario: Viewing help text on contact event core fields
    Given I am logged in as a super user
      And a basic morbidity event exists
      And there is a contact on the event named "Wilson"
     When I am on the contact event edit page
     Then I should see help text for all contact event core fields

  Scenario: Viewing help text on place event core fields
    Given I am logged in as a super user
      And a basic morbidity event exists
      And there is a place on the event named "McW"
     When I am on the place event edit page
     Then I should see help text for all place event core fields

  Scenario: Viewing help text on encounter event core fields
    Given I am logged in as a super user
      And a basic morbidity event exists
      And there is an associated encounter event
     When I am on the encounter event edit page
     Then I should see help text for all encounter event core fields

  Scenario: Viewing all the core fields
    Given I am logged in as a super user
     When I go to view all core fields
     Then I should see all the core fields
