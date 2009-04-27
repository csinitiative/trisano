Feature: Routing events through a set workflow.

  To simplify the way which morbidity events are processed by users
  I want to be able to route events through diffent states.

  Scenario: Reopening an event already received by the state.
    Given I am logged in as a lhd manager
    And a morbidity event exists in Bear River with the disease African Tick Bite Fever
    And that the event has been sent to the state
    
    When I navigate to the event show page
    And I click "Reopen"

    Then the Morbidity event is returned to the "Completed" state

  Scenario: Reopening an event already approved by the state.
    Given I am logged in as a lhd manager
    And a morbidity event from my jurisdiction has already been approved by the state
    
    When I navigate to the event show page
    And I click "Reopen"

    Then the Morbidity event is returned to the "Completed" state
