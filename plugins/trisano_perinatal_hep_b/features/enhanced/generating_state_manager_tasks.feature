Feature: Generating P Hep B tasks for that state manager

  To ensure that the correct infant treatments make it to the hospital
  on time, the state manager needs to be alerted when a P Hep B CMR is
  updated w/ complete expected delivery data.

  @flush_core_fields_cache
  Scenario: Completing expected delivery data
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And Perinatal Hep B specific callbacks are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And there is an expected delivery facility named "New Expected Delivery Facility"
     When I am on the morbidity event edit page
      And I search for an expected delivery facility
      And I select an expected delivery facility from the list
      And I fill in the expected delivery date
      And I save and exit
     Then I should see "Hepatitis B Pregnancy Event: expected delivery date and hospital entered"

  @flush_core_fields_cache
  Scenario: Completing expected delivery data by entering a new expected delivery facility
    Given I am logged in as a super user
      And disease "Hepatitis B Pregnancy Event" exists
      And Perinatal Hep B specific callbacks are loaded
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
      And the expected delivery date is set to 3 days from now
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I am on the morbidity event edit page
      And I fill in "Expected delivery facility" with "Arkham"
      And I save and exit
     Then I should see "Hepatitis B Pregnancy Event: expected delivery date and hospital entered"

