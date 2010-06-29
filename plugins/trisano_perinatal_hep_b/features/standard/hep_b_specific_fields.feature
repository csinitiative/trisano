Feature: Hep B specific pregnancy fields

  In order to properly manage perinatal Hep B cases, Epidemiologists
  need to be able to enter additional pregnancy information about
  woman w/ chronic or acute hep b

  Scenario: Viewing a new cmr event
    Given I am logged in as a super user
     When I go to the new CMR page
     Then I should see "New CMR"
      And I should not see expected delivery fields

  Scenario: Editing an event w/ no disease specific fields
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
     When I go to edit the CMR
     Then I should see "Edit morbidity event"
      And I should not see expected delivery fields

  Scenario: Editing an event w/ Acute Hepatitis B
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B, acute
      And "Hepatitis B, acute" has disease specific core fields
     When I go to edit the CMR
     Then I should see expected delivery facility fields
     When I fill in "Expected delivery facility" with "Delivery Here Clinic"
      And I fill in "Expected delivery date" with "January 10, 2020"
      And I enter the expected delivery facility phone number as:
        | area_code | phone_number | extension |
        |       123 |     456-7890 |        88 |
      And I save the edit event form
     Then I should be on the show CMR page
      And I should see expected delivery data
      And I should see "Delivery Here Clinic"
      And I should see "2020-01-10"
      And I should see the expected delivery facility phone number as:
        | area_code | phone_number | extension |
        | (123)     |     456-7890 |        88 |




