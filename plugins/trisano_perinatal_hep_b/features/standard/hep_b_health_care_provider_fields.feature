Feature: Hep B specific health care provider fields

  In order to properly manage perinatal Hep B cases, Epidemiologists
  need to be able to enter additional pregnancy information about
  health care providers for women /w Hepatitis B

  Scenario: Viewing a new cmr event
    Given I am logged in as a super user
     When I go to the new CMR page
     Then I should see "New CMR"
      And I should not see health care provider fields

  Scenario: Editing an event w/ no disease specific fields
    Given I am logged in as a super user
      And a morbidity event exists with the disease African Tick Bite Fever
     When I go to edit the CMR
     Then I should see "Edit morbidity event"
      And I should not see health care provider fields

  Scenario: Editing an event w/ Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I go to edit the CMR
     Then I should see health care provider fields
     When I enter the health care provider name as:
        | first_name | middle_name | last_name |
        |       Johnny |  B.    |     HcProvider |
       And I enter the health care provider phone number as:
         | area_code | phone_number | extension |
         |       123 |     456-7890 |        88 |
      And I save the edit event form
     Then I should be on the show CMR page
      And I should see health care provider data
      And I should see "Johnny"
      And I should see "B."
      And I should see "HcProvider"
      And I should see the health care provider phone number as:
        | area_code | phone_number | extension |
        | (123)     |     456-7890 |        88 |
     When I go to print the Clinical CMR data
     Then I should see printed health care provider fields
      And I should see printed health care provider phone numbers:
        | Area code | Phone number | Extension |
        | (123)     |     456-7890 |        88 |

