Feature: Event treatment fields

  Background:
    Given I am logged in as a super user

  Scenario: Viewing treatment names associated with a morbidity event
    Given a morbidity event exists with the disease African Tick Bite Fever
      And the morbidity event has the following treatments:
        | treatment_name |
        | rubbings       |
        | leeches        |
        | bleeding       |
    When I navigate to the morbidity event show page
    Then I should see "rubbings"
      And I should see "leeches"
      And I should see "bleeding"

  Scenario: Viewing treatment names associated with a contact event
    Given a simple morbidity event for last name "Smoker"
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
      And the contact event has the following treatments:
        | treatment_name |
        | rubbings       |
        | leeches        |
        | bleeding       |
    When I am on the morbidity event edit page
      And I follow "Show Contact"
    Then I should see "rubbings"
      And I should see "leeches"
      And I should see "bleeding"

  Scenario: Viewing treatment names associated with an encounter event
    Given a morbidity event exists with the disease African Tick Bite Fever
      And there is an associated encounter event
      And the encounter event has the following treatments:
        | treatment_name |
        | rubbings       |
        | leeches        |
        | bleeding       |
    When I am on the morbidity event edit page
    Then I should see "rubbings"
     And I should see "leeches"
     And I should see "bleeding"
    When I follow "Show Encounter"
    Then I should see "rubbings"
     And I should see "leeches"
     And I should see "bleeding"
