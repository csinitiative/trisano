Feature: Alerting a state manager with a Hepatitis B Pregnancy Event

  In order to ensure that the necessary vaccinations get to the
  correct hosptial, on time, a state manager needs to be alerted about
  updates to Hepatits B Pregnancy Events

  @pending
  Scenario: Assigning a State Manager to a Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And a state manager exists named "Joe Shlabotnik"
      And a Hepatitis B Pregnancy Event exists
     When I go to edit the CMR
      And I select "Joe Shlabotnik" from "State manager"
      And I save the edit event form
     Then I should be on the show CMR page
      And I should see state manager "Joe Shlabotnik"
     When I print the Administrative CMR data
     Then I should see state manager "Joe Shlabotnik" printed
