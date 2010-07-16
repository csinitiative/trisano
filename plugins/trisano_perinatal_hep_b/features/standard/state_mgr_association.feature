Feature: Alerting a state manager with a Hepatitis B Pregnancy Event

  In order to ensure that the necessary vaccinations get to the
  correct hosptial, on time, a state manager needs to be alerted about
  updates to Hepatits B Pregnancy Events

  Scenario: Assigning a State Manager to a Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And a state manager exists named "Joe Shlabotnik"
      And a Hepatitis B Pregnancy Event exists
     When I go to edit the CMR
      And I select "Joe Shlabotnik" from "State manager"
      And I save the edit event form
     Then I should be on the show CMR page
      And I should see state manager "Joe Shlabotnik"
     When I go to print the Administrative CMR data
     Then I should see state manager "Joe Shlabotnik" printed

  Scenario: Cannot assign State Manager unless CMR is a Hepatitis B Pregnancy Event
    Given I am logged in as a super user
      And "Hepatitis B Pregnancy Event" has disease specific core fields
      And a state manager exists named "Joe Shlabotnik"
      And a morbidity event exists with the disease African Tick Bite Fever
     When I go to edit the CMR
     Then I should not see the "State manager" select

