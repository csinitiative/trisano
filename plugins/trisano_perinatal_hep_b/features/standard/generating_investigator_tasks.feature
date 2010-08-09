Feature: Generating tasks for investigators

  @perinatal_hep_b_callbacks
  Scenario: Entering a Hepatitis B Dose 3 treatment on a Hep B case
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And the hep b disease specific selections are loaded
      And an investigator is assigned to the event
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
    When I go to edit the CMR
      And I follow "Edit Contact"
      And I select "Infant" from "contact_event_participations_contact_attributes_contact_type_id"
      And I select "Yes" from "Treatment given"
      And I select "Hepatitis B Dose 3" from "contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I enter a valid treatment date of 2 days ago
      And I press "Save & Exit"
    Then I should see "Hepatitis B Dose 3"
      And I should only see 1 "Post serological testing due for Hepatitis B infant contact." task
    When I go to edit the CMR
      And I follow "Edit Contact"
      And I enter a valid treatment date of 3 days ago
      And I press "Save & Exit"
    Then I should only see 1 "Post serological testing due for Hepatitis B infant contact." task


  @perinatal_hep_b_callbacks
  Scenario: Entering a Hepatitis B - Comvax Dose 4 treatment on a Hep B case
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And the hep b disease specific selections are loaded
      And an investigator is assigned to the event
      And the morbidity event has the following contacts:
        | last_name | first_name |
        | Davis     | James      |
    When I go to edit the CMR
      And I follow "Edit Contact"
      And I select "Infant" from "contact_event_participations_contact_attributes_contact_type_id"
      And I select "Yes" from "Treatment given"
      And I select "Hepatitis B - Comvax Dose 4" from "contact_event[interested_party_attributes][treatments_attributes][0][treatment_id]"
      And I enter a valid treatment date of 2 days ago
      And I press "Save & Exit"
    Then I should see "Hepatitis B - Comvax Dose 4"
      And I should only see 1 "Post serological testing due for Hepatitis B infant contact." task
    When I go to edit the CMR
      And I follow "Edit Contact"
      And I enter a valid treatment date of 3 days ago
      And I press "Save & Exit"
    Then I should only see 1 "Post serological testing due for Hepatitis B infant contact." task


