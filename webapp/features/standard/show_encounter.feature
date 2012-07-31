Feature: Showing encounters

  To allow epi's to get a quick overview of an encounter
  Encounters have a show mode

  Scenario: Navigating to show mode from morb show mode
    Given a basic morbidity event exists
      And there is an associated encounter event
     When I am on the show cmr page
      And I follow "Show Encounter"
     Then I should get a 200 response
      And I should be on the encounter event show page

  Scenario: Navigating to show mode from assessemnt show mode
    Given a basic assessment event exists
      And there is an associated encounter event
     When I am on the AE show page
      And I follow "Show Encounter"
     Then I should get a 200 response
      And I should be on the encounter event show page
