Feature: Adding multiple treatments to a CMR

  Since there can be many treatments assocaited with a case
  As an investigator
  I need to be able enter multiple treatments into the CMR

  Scenario: Entering multiple treatments into a new CMR
    Given I am logged in as a super user
      And the following treatments exist
        | treatment_name | default |
        | Leeches        | true    |
        | Whiskey        | true    |
        | Eye of Newt    | true    |
     When I go to the new CMR page
      And I enter basic CMR data
      And I select treatment "Whiskey"
      And I add treatment "Leeches"
      And I press "Save & Exit"
      And I wait for the page to load
     Then I should see "CMR was successfully created"
      And I should see "Leeches"
      And I should see "Whiskey"

  Scenario: Removing a treatment from a CMR
    Given I am logged in as a super user
      And a basic morbidity event exists
      And the event has the following treatments:
        | treatment_name | default |
        | Leeches        | true    |
        | Whiskey        | true    |
      And I am on the morbidity event edit page
     When I remove treatment "Whiskey"
      And I press "Save & Exit"
      And I wait for the page to load
     Then I should see "CMR was successfully updated"
      And I should see "Leeches"
      And I should not see "Whiskey"
