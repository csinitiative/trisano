Feature: Generating tasks for Hep B state managers when expected delivery data is entered

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
      And I should not see "Hepatitis B Pregnancy Event: expected delivery date and hospital entered"

  @perinatal_hep_b_callbacks
  Scenario: Updating the expected delivery date on a Hep B case
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
      And the expected delivery date is set to 3 days from now
     When I go to edit the CMR
      And I change the expected delivery date to 2 days from now
      And I save the event
     Then I should only see 1 "Hepatitis B Pregnancy Event: expected delivery date entered" task

  @perinatal_hep_b_callbacks
  Scenario: Deleting the expected delivery date on a Hep B case
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
      And the expected delivery date is set to 3 days from now
     When I go to edit the CMR
      And I fill in "Expected delivery date" with ""
      And I save the event
     Then I should not see "Hepatitis B Pregnancy Event: expected delivery date entered"

  @perinatal_hep_b_callbacks
  Scenario: State manager assigned to a case recieves a task when expected due date and expected hospital entered
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And a state manager is assigned to the event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I go to edit the CMR
      And I change the expected delivery date to 3 days from now
      And I fill in "Expected delivery facility" with "Arkham"
      And I save the event
     Then I should see "Hepatitis B Pregnancy Event: expected delivery date entered"
      And I should see "Hepatitis B Pregnancy Event: expected delivery date and hospital entered"

  @perinatal_hep_b_callbacks
  Scenario: State manager assigned to a case recieves a task when expected due date existss and expected hospital entered
    Given I am logged in as a super user
      And a morbidity event exists with the disease Hepatitis B Pregnancy Event
      And the expected delivery date is set to 3 days from now
      And a state manager is assigned to the event
      And "Hepatitis B Pregnancy Event" has disease specific core fields
     When I go to edit the CMR
      And I fill in "Expected delivery facility" with "Arkham"
      And I save the event
     Then I should see "Hepatitis B Pregnancy Event: expected delivery date and hospital entered"
