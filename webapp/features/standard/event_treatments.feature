Feature: Event treatment fields

  Scenario: Viewing treatment names associated with a morbidity event
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
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
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
      And there is a contact on the event named Jones
      And the contact event has the following treatments:
        | treatment_name |
        | rubbings       |
        | leaches        |
        | bleeding       |
    When I navigate to the contact event show page
    Then I should see "rubbings"
      And I should see "leaches"
      And I should see "bleeding"
