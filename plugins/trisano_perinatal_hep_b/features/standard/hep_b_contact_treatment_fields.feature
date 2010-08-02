Feature: Hep B specific contact treatment fields

  Scenario: Editing p-hep-b contact event w/ no disease specific fields
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
    When I go to edit the CMR
      And I follow "Edit Contact"
    Then I should not see the p-hep-b treatment fields

  Scenario: Editing p-hep-b contact event w/ disease specific fields
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
    When I go to edit the CMR
      And I follow "Edit Contact"
    Then I should see the p-hep-b treatment fields
    When I select "Yes" from "Treatment given"
      And I select "Hep B Dose 1 Vaccination" from "contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I enter a valid treatment date of 2 days ago
      And I press "Save & Exit"
    Then I should see "Hep B Dose 1 Vaccination"
      And the treatment date of 2 days ago should be visible in show format




