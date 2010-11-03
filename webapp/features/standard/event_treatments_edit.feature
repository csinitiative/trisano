Features: Editing treatments on events

  Background:
    Given I am logged in as a super user

  Scenario: Inactive treatments should not show up
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
    When I go to edit the CMR
    Then I should see "Leeches"
    And I should not see "Garlic"

    When I follow "Edit Contact"
    Then I should see "Leeches"
    And I should not see "Garlic"

    When I follow "Smoker"
    And I fill in "Encounter Date" with "November 01, 2010"
    And I save the event
    And I follow "Edit Encounter"
    Then I should see "Leeches"
    And I should not see "Garlic"



