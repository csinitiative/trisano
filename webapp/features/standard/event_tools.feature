Feature: Event tools

  Scenario: Full set of tools appears in edit mode
    Given I am logged in as a super user
      And a morbidity event exists with the disease Mumps
     When I go to edit the CMR
     Then I should see the full set of tools in the right place

