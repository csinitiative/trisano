Feature: Event treatment fields

  Background:
    Given I am logged in as a super user

  Scenario: Viewing treatment names associated with a morbidity event
    Given a simple morbidity event for last name "Smoker"
      And the morbidity event has the following treatments:
        | treatment_name |
        | rubbings     |
        | leaches     |
        | bleeding     |
    When I navigate to the event show page
    Then I should see "rubbings"
      And I should see "leaches"
      And I should see "bleeding"

  Scenario: Viewing treatment names associated with a contact event
    Given a simple morbidity event for last name "Smoker"
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
      And the following treatments exist
        | treatment_name | active |
        | Rubbings       | true   |
        | Foot massage   | true   |
        | Leeches        | true   |
        | Garlic         | false  |
    When I navigate to the contact event show page
    Then I should see "Leeches"
      And I should not see "Garlic"
