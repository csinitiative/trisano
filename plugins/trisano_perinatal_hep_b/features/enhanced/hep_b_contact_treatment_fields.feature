Feature: Hep B specific contact treatment fields

  Scenario: Adding multiple contact treatments at one time
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And there is a contact on the event named Davis
    When I am on the contact event edit page
      And I add a p-hep-b treatment "HBIG" on with a date 5 days ago
      And I add a 2nd p-hep-b treatment "Hepatitis B Dose 1" on with a date 4 days ago
      And I save and exit
    Then I should see the treatment "HBIG" on with a date 5 days ago
      And I should see the treatment "Hepatitis B Dose 1" on with a date 4 days ago
    When I am on the contact event edit page
      And I remove the 1st treatment
      And I save and exit
    Then I should not see the treatment "HBIG" on with a date 5 days ago
     
    




