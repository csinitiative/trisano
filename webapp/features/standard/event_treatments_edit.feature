Features: Editing treatments on events

  Background:
    Given I am logged in as a super user

  Scenario: Inactive treatments should not show up
    Given a simple morbidity event for last name "Smoker"
    And the morbidity event has the following contacts:
    | last_name | first_name |
    | Davis     | James      |
    And the following treatments exist
    | treatment_name | active | default |
    | Rubbings       | true   | true    |
    | Foot massage   | true   | true    |
    | Leeches        | true   | true    |
    | Garlic         | false  | true    |
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

  Scenario: An inactive treatment should show up if it is already associated with an event
    Given a simple morbidity event for last name "Smoker"
    And the morbidity event has the following contacts:
    | last_name | first_name |
    | Davis     | James      |
    And the morbidity event has the following treatments:
    | treatment_name | active | default |
    | Rubbings       | false  | true    |
    And the contact event has the following treatments:
    | treatment_name | active | default |
    | Bleedings      | false  | true    |
    And there is an associated encounter event
    And the encounter event has the following treatments:
    | treatment_name | active | default |
    | Squeezings     | false  | true    |

    When I go to edit the CMR
    Then I should see "Rubbings"

    When I follow "Edit Contact"
    Then I should see "Bleedings"

    When I follow "Smoker"
    And I follow "Edit Encounter"
    Then I should see "Squeezings"

  Scenario: Selected treatments should appear in show mode for morbidity events
    Given a simple morbidity event for last name "Smoker"
      And the following treatments exist
        | treatment_name | active | default |
        | Rubbings       | true   | true    |
        | Foot massage   | true   | true    |
        | Leeches        | true   | true    |
        | Garlic         | false  | true    |
    When I go to edit the CMR
      And I select "Leeches" from "morbidity_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I save the event
      And I navigate to the morbidity event show page
    Then I should see "Leeches"
      And I should not see "Rubbings"
      And I should not see "Foot massage"
      And I should not see "Garlic"

  Scenario: Selected treatments should appear in show mode for contact events
    Given a simple morbidity event for last name "Smoker"
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
      And the following treatments exist
        | treatment_name | active | default |
        | Rubbings       | true   | true    |
        | Foot massage   | true   | true    |
        | Leeches        | true   | true    |
        | Garlic         | false  | true    |
    When I am on the morbidity event edit page
      And I follow "Edit Contact"
      And I select "Leeches" from "contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I save the contact event
      And I am on the morbidity event edit page
      And I follow "Show Contact"
    Then I should see "Leeches"
      And I should not see "Rubbings"
      And I should not see "Foot massage"
      And I should not see "Garlic"

  Scenario: Selected treatments should appear in show mode for encounter events
    Given a morbidity event exists with the disease African Tick Bite Fever
      And there is an associated encounter event
      And the following treatments associated with the disease "African Tick Bite Fever":
        | treatment_name | active | default |
        | Rubbings       | true   | true    |
        | Foot massage   | true   | true    |
        | Leeches        | true   | true    |
        | Garlic         | false  | true    |
    When I am on the morbidity event edit page
      And I follow "Edit Encounter"
      And I select "Leeches" from "encounter_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I save the encounter event
      And I am on the morbidity event edit page
      And I follow "Show Encounter"
    Then I should see "Leeches"
      And I should not see "Rubbings"
      And I should not see "Foot massage"
      And I should not see "Garlic"
