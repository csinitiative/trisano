Feature: Generating tasks for state managers when expected delivery data is entered

  To ensure that the correct vaccines make it to the hospital on time,
  then state managers need to be alerted when expected delivery info
  is entered into Hep B events.

  @perinatal_hep_b_callbacks
  Scenario: Entering an expected delivery date on a Hep B case
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
     When I go to edit the CMR
      And I enter a valid expected delivery date
      And I save the event
     Then I should see "Hepatitis B Pregnancy Event: expected delivery date entered"
